*> The snow and ice top layer (docs/protocol/35-worldgen-features-5-water-and-surface.md section 8; registry id 19, freeze_top_layer) and the biome temperature it needs (33 section 4.5, 10
*> section 10 Open question 8).
*>
*> FR-TEMPERATURE: the temperature of a biome at a position: the base temperature of the biome (CBI-TEMPERATURE, read from the biome entry by BIOME-CLIMATE), for a biome with the temperature
*> modifier "frozen" first the frozen noise (f = FROZEN_TEMPERATURE_NOISE(x * 0.05, z * 0.05) * 7, the layers of slots 3 to 5 of F351-SIMPLEX-T with the amplitudes 0.14285715, 0.2857143 and
*> 0.5714286 at the frequencies 1, 0.5 and 0.25; the temperature is 0.2 when f + BIOME_INFO_NOISE(x * 0.2, z * 0.2) < 0.3 and BIOME_INFO_NOISE(x * 0.09, z * 0.09) < 0.8), then above
*> sea level + 17 the height adjustment base - (N * 8 + y - (sea + 17)) * 0.05 / 40 with N = TEMPERATURE_NOISE(x / 8, z / 8) (slot 2), every step rounded to a float.
*>
*> FD-FREEZE-NODE compiles the feature into a row of FD-WA (WA-I(1) the block index of ice, WA-I(2) of snow; the pool 1 the tag cannot_support_snow_layer); FR-FREEZE places it: for each of the 16 x 16 columns of the chunk, in the order x outer, z inner, with h the MOTION_BLOCKING height, top = (x, h, z) and
*> below = (x, h - 1, z): ice replaces a source water block at below where the temperature at below is under 0.15, and a snow layer is written at top where the biome has precipitation,
*> the temperature at top is under 0.15, top is air and the snow layer can stand on the block below (the block below is not in cannot_support_snow_layer and has a collision shape, CB-SOLID: the full-face
*> test of the document is approximated by "has a collision shape", and the tag support_override_snow_layer adds nothing because the block below the MOTION_BLOCKING top always has one; a snow layer
*> below needs 8 layers: the generator makes no layer above 1); the block
*> below then gets snowy = true when it has that property. Block light is taken as 0 (35-5 Open question 1: no light exists while features run). No random use.
*>
*> Entry points: FR-TEMPERATURE USING biome id (0-based), x, y, z, sea level, temperature out (FLOAT-LONG); FD-FREEZE-NODE USING doc, node, row out; FR-FREEZE USING feature, x, z (the chunk
*> origin), result out.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-TEMPERATURE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-SLOT                BINARY-LONG.
 01 WS-NX                  FLOAT-LONG.
 01 WS-NZ                  FLOAT-LONG.
 01 WS-N                   FLOAT-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-INFO                FLOAT-LONG.
 01 WS-INFO2               FLOAT-LONG.
 01 WS-V                   FLOAT-LONG.
 01 WS-LIMIT               BINARY-LONG.
 01 WS-THRESHOLD           FLOAT-LONG VALUE 0.3.
 01 WS-TOP-INFO            FLOAT-LONG VALUE 0.8.
 01 WS-MELT                FLOAT-LONG VALUE 0.2.
 01 WS-FIVE-HUNDREDTH      FLOAT-LONG VALUE 0.05.
 01 WS-FORTY               FLOAT-LONG VALUE 40.
 01 WS-AMPS.
    05 WS-AMP              FLOAT-LONG OCCURS 3 TIMES.
 01 WS-FREQS.
    05 WS-FREQ             FLOAT-LONG OCCURS 3 TIMES.
 01 WS-READY               BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-SEA                  BINARY-LONG.
 01 L-TEMPERATURE          FLOAT-LONG.
 PROCEDURE DIVISION USING L-ID L-X L-Y L-Z L-SEA L-TEMPERATURE.
     IF WS-READY = 0
         MOVE 0.14285715 TO WS-AMP(1)
         MOVE 0.2857143 TO WS-AMP(2)
         MOVE 0.5714286 TO WS-AMP(3)
         MOVE 1 TO WS-FREQ(1)
         MOVE 0.5 TO WS-FREQ(2)
         MOVE 0.25 TO WS-FREQ(3)
         PERFORM VARYING WS-SLOT FROM 1 BY 1 UNTIL WS-SLOT > 3
             CALL "FR-F32" USING WS-AMP(WS-SLOT)
         END-PERFORM
         MOVE 1 TO WS-READY
     END-IF
     MOVE CBI-TEMPERATURE(L-ID + 1) TO L-TEMPERATURE
     IF CBI-FROZEN(L-ID + 1) = 1
         MOVE 0 TO WS-F
         PERFORM VARYING WS-SLOT FROM 1 BY 1 UNTIL WS-SLOT > 3
             COMPUTE WS-NX = L-X * 0.05 * WS-FREQ(WS-SLOT)
             COMPUTE WS-NZ = L-Z * 0.05 * WS-FREQ(WS-SLOT)
             COMPUTE WS-LIMIT = WS-SLOT + 2
             CALL "F351-SIMPLEX-T" USING WS-LIMIT WS-NX WS-NZ WS-N
             COMPUTE WS-F = WS-F + WS-N * WS-AMP(WS-SLOT)
         END-PERFORM
         COMPUTE WS-F = WS-F * 7
         CALL "FR-F32" USING WS-F
         COMPUTE WS-NX = L-X * 0.2
         COMPUTE WS-NZ = L-Z * 0.2
         MOVE 1 TO WS-LIMIT
         CALL "F351-SIMPLEX-T" USING WS-LIMIT WS-NX WS-NZ WS-INFO
         COMPUTE WS-V = WS-F + WS-INFO
         CALL "FR-F32" USING WS-V
         IF WS-V < WS-THRESHOLD
             COMPUTE WS-NX = L-X * 0.09
             COMPUTE WS-NZ = L-Z * 0.09
             CALL "F351-SIMPLEX-T" USING WS-LIMIT WS-NX WS-NZ WS-INFO2
             IF WS-INFO2 < WS-TOP-INFO
                 MOVE WS-MELT TO L-TEMPERATURE
                 CALL "FR-F32" USING L-TEMPERATURE
             END-IF
         END-IF
     END-IF
     COMPUTE WS-LIMIT = L-SEA + 17
     IF L-Y > WS-LIMIT
         COMPUTE WS-NX = L-X / 8
         COMPUTE WS-NZ = L-Z / 8
         MOVE 2 TO WS-SLOT
         CALL "F351-SIMPLEX-T" USING WS-SLOT WS-NX WS-NZ WS-N
         COMPUTE WS-V = WS-N * 8
         CALL "FR-F32" USING WS-V
         COMPUTE WS-V = WS-V + L-Y
         CALL "FR-F32" USING WS-V
         COMPUTE WS-V = WS-V - WS-LIMIT
         CALL "FR-F32" USING WS-V
         COMPUTE WS-V = WS-V * WS-FIVE-HUNDREDTH
         CALL "FR-F32" USING WS-V
         COMPUTE WS-V = WS-V / WS-FORTY
         CALL "FR-F32" USING WS-V
         COMPUTE L-TEMPERATURE = L-TEMPERATURE - WS-V
         CALL "FR-F32" USING L-TEMPERATURE
     END-IF
     GOBACK.
 END PROGRAM FR-TEMPERATURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-FREEZE-NODE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ICE                 PIC X(48) VALUE "minecraft:ice".
 01 WS-SNOW                PIC X(48) VALUE "minecraft:snow".
 01 WS-TAG1                PIC X(112) VALUE "minecraft:cannot_support_snow_layer".
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-ROW.
     MOVE 0 TO L-ROW
     IF FD-WA-COUNT >= FD-MAX-WA
         MOVE 1 TO FD-BAD
         GOBACK
     END-IF
     ADD 1 TO FD-WA-COUNT
     MOVE FD-WA-COUNT TO WS-ROW
     INITIALIZE FD-WA(WS-ROW)
     MOVE WS-ROW TO L-ROW
     CALL "FD-BLOCK-INDEX" USING WS-ICE WA-I(WS-ROW, 1)
     CALL "FD-BLOCK-INDEX" USING WS-SNOW WA-I(WS-ROW, 2)
     IF WA-I(WS-ROW, 1) = 0 OR WA-I(WS-ROW, 2) = 0
         MOVE 1 TO FD-BAD
     END-IF
     COMPUTE WA-START(WS-ROW, 1) = FD-POOL-COUNT + 1
     CALL "FD-TAG-BLOCKS" USING WS-TAG1 WA-N(WS-ROW, 1)
     GOBACK.
 END PROGRAM FD-FREEZE-NODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-SNOWY.
*> USING state, state out: the state of the same block with snowy = true (the state itself when the block has no such property). The answers are remembered per block table.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-NAME                PIC X(40) VALUE "snowy".
 01 WS-VALUE               PIC X(40) VALUE "true".
 01 WS-FOUND               BINARY-LONG.
 01 WS-MEMO-EPOCH          BINARY-LONG VALUE -1.
 01 WS-MEMO-COUNT          BINARY-LONG.
 01 WS-MEMO.
    05 WS-M OCCURS 64 TIMES.
       10 WS-M-STATE       BINARY-LONG.
       10 WS-M-OUT         BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-HIT                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-OUT.
     IF WS-MEMO-EPOCH NOT = CB-EPOCH
         MOVE CB-EPOCH TO WS-MEMO-EPOCH
         MOVE 0 TO WS-MEMO-COUNT
     END-IF
     MOVE 0 TO WS-HIT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-MEMO-COUNT OR WS-HIT = 1
         IF WS-M-STATE(WS-I) = L-STATE
             MOVE WS-M-OUT(WS-I) TO L-OUT
             MOVE 1 TO WS-HIT
         END-IF
     END-PERFORM
     IF WS-HIT = 0
         CALL "FD-STATE-SET" USING L-STATE WS-NAME WS-VALUE L-OUT WS-FOUND
         IF WS-MEMO-COUNT < 64
             ADD 1 TO WS-MEMO-COUNT
             MOVE L-STATE TO WS-M-STATE(WS-MEMO-COUNT)
             MOVE L-OUT TO WS-M-OUT(WS-MEMO-COUNT)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM FR-SNOWY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-FREEZE-COLUMN.
*> USING feature row, x, z, h (the MOTION_BLOCKING height), biome id: steps 2 and 3 of section 8 for one column.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY FEATLEVEL.
 COPY CBLOCKS.
 01 WS-BELOW               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-LIMIT               FLOAT-LONG VALUE 0.15.
 01 WS-WATER-STATE         BINARY-LONG.
 01 WS-ICE-STATE           BINARY-LONG.
 01 WS-SNOW-STATE          BINARY-LONG.
 01 WS-SNOWY-STATE         BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-HAS                 BINARY-LONG.
 01 WS-STAND               BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-BIOME                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-X L-Z L-H L-BIOME.
     MOVE WA-I(L-ROW, 1) TO WS-BLOCK
     MOVE CB-DEFAULT-STATE(WS-BLOCK) TO WS-ICE-STATE
     MOVE WA-I(L-ROW, 2) TO WS-BLOCK
     MOVE CB-DEFAULT-STATE(WS-BLOCK) TO WS-SNOW-STATE
     MOVE FL-B-WATER TO WS-BLOCK
     MOVE CB-DEFAULT-STATE(WS-BLOCK) TO WS-WATER-STATE
     COMPUTE WS-BELOW = L-H - 1
*>   2. ice where a source of water at below is in cold air
     CALL "FL-GET-STATE" USING L-X WS-BELOW L-Z WS-STATE
     IF WS-STATE = WS-WATER-STATE
         CALL "FR-TEMPERATURE" USING L-BIOME L-X WS-BELOW L-Z FL-SEA WS-T
         IF WS-T < WS-LIMIT
             CALL "FL-SET-STATE" USING L-X WS-BELOW L-Z WS-ICE-STATE WS-FLAGS WS-OK
         END-IF
     END-IF
*>   3. a layer of snow where the biome has snow: the biome has precipitation, it is cold at top, top is air and the snow can stand on the block below
     IF CBI-PRECIPITATION(L-BIOME + 1) = 1
         CALL "FR-TEMPERATURE" USING L-BIOME L-X L-H L-Z FL-SEA WS-T
         CALL "FL-GET-STATE" USING L-X L-H L-Z WS-STATE
         CALL "FL-CLASS" USING WS-STATE WS-CLASS
         IF WS-T < WS-LIMIT AND WS-CLASS = 1
             CALL "FL-GET-STATE" USING L-X WS-BELOW L-Z WS-STATE
             CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
             CALL "FL-CLASS" USING WS-STATE WS-CLASS
             MOVE 0 TO WS-STAND
             IF WS-BLOCK > 0 AND WS-CLASS = 0
                 MOVE CB-SOLID(WS-BLOCK) TO WS-STAND
                 CALL "FR-POOL-HAS" USING WA-START(L-ROW, 1) WA-N(L-ROW, 1) WS-BLOCK WS-HAS
                 IF WS-HAS = 1
                     MOVE 0 TO WS-STAND
                 END-IF
             END-IF
             IF WS-STAND = 1
                 CALL "FL-SET-STATE" USING L-X L-H L-Z WS-SNOW-STATE WS-FLAGS WS-OK
                 CALL "FR-SNOWY" USING WS-STATE WS-SNOWY-STATE
                 IF WS-SNOWY-STATE NOT = WS-STATE
                     CALL "FL-SET-STATE" USING L-X WS-BELOW L-Z WS-SNOWY-STATE WS-FLAGS WS-OK
                 END-IF
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM FR-FREEZE-COLUMN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-FREEZE.
*> USING feature, origin x, origin z, result out (always 1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY FEATLEVEL.
 COPY CBLOCKS.
 COPY CELLS.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-TOP-Y               BINARY-LONG.
 01 WS-LAYER               BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-BELOW               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-BIOME               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-FT                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-FT L-X L-Z L-RESULT.
     MOVE 1 TO L-RESULT
     MOVE FT-A(L-FT) TO WS-ROW
*>   the highest layer of the chunk that holds anything but air: the height scans start there
     SET ADDRESS OF CE-CHUNK TO FL-ADDR
     MOVE FL-HEIGHT TO WS-LAYER
     MOVE 0 TO WS-FOUND
     PERFORM UNTIL WS-LAYER = 0 OR WS-FOUND = 1
         COMPUTE WS-CELL = (WS-LAYER - 1) * 256
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 256 OR WS-FOUND = 1
             IF CE-STATE(WS-CELL + WS-I) NOT = FL-S-AIR
                 MOVE 1 TO WS-FOUND
             END-IF
         END-PERFORM
         IF WS-FOUND = 0
             SUBTRACT 1 FROM WS-LAYER
         END-IF
     END-PERFORM
     COMPUTE WS-TOP-Y = FL-MIN-Y + WS-LAYER - 1
     PERFORM VARYING WS-DX FROM 0 BY 1 UNTIL WS-DX > 15
         PERFORM VARYING WS-DZ FROM 0 BY 1 UNTIL WS-DZ > 15
             COMPUTE WS-X = L-X + WS-DX
             COMPUTE WS-Z = L-Z + WS-DZ
*>           the MOTION_BLOCKING height: one above the first fluid or solid block from the top
             MOVE FL-MIN-Y TO WS-H
             MOVE 0 TO WS-FOUND
             PERFORM VARYING WS-Y FROM WS-TOP-Y BY -1 UNTIL WS-Y < FL-MIN-Y OR WS-FOUND = 1
                 CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
                 CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
                 CALL "FL-CLASS" USING WS-STATE WS-CLASS
                 IF WS-CLASS = 2 OR WS-CLASS = 3
                     MOVE 1 TO WS-FOUND
                 END-IF
                 IF WS-FOUND = 0 AND WS-BLOCK > 0 AND WS-CLASS NOT = 1
                     IF CB-SOLID(WS-BLOCK) = 1
                         MOVE 1 TO WS-FOUND
                     END-IF
                 END-IF
                 IF WS-FOUND = 1
                     COMPUTE WS-H = WS-Y + 1
                 END-IF
             END-PERFORM
             COMPUTE WS-BELOW = WS-H - 1
             IF WS-BELOW >= FL-MIN-Y
                 CALL "FL-BIOME-ID" USING WS-X WS-H WS-Z WS-BIOME
                 CALL "FR-FREEZE-COLUMN" USING WS-ROW WS-X WS-Z WS-H WS-BIOME
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM FR-FREEZE.
