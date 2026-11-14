*> Implementation test of the snow and ice top layer and the biome temperature (docs/protocol/35-worldgen-features-5-water-and-surface.md section 8, 33 section 4.5, 10 section 10 Open question 8;
*> core/src/feat-freeze.cob, core/src/biome-climate.cob): BIOME-CLIMATE reads has_precipitation, temperature and the frozen modifier from the network NBT of a biome entry (BIOMES-OPEN fills
*> CORE-BIOMES with them); FR-TEMPERATURE gives the base temperature up to sea level + 17, the height adjustment above it (an independent evaluation with a tolerance for the float steps) and
*> the frozen noise rule for a frozen biome; the feature turns a source of water into ice in cold air, lays one layer of snow on a block that can bear it (and makes the grass below snowy),
*> and leaves warm biomes, flowing water, water below ice and biomes without precipitation as the document says.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-35-5-FREEZE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 COPY CELLS.
 COPY FEATDATA.
 COPY FEATLEVEL.
 COPY FEATINDEX.
 COPY PROTO.
 COPY XORO.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/water".
 01 WS-PTR                 USAGE POINTER.
 01 WS-A                   PIC X(304640) BASED.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-FT                  BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-CX                  BINARY-LONG VALUE 1.
 01 WS-CZ                  BINARY-LONG VALUE 2.
 01 WS-MIN                 BINARY-LONG VALUE -64.
 01 WS-HEIGHT              BINARY-LONG VALUE 384.
 01 WS-SEA                 BINARY-LONG VALUE 63.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-OK                  BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 5.
 01 WS-KEY                 PIC X(112).
 01 WS-NAME                PIC X(48).
 01 WS-FTKEY               PIC X(80).
 01 WS-PAIRS               PIC X(160).
 01 WS-CASE                PIC X(200).
 01 WS-OBS                 BINARY-LONG.
 01 WS-EXP                 BINARY-LONG.
 01 WS-REG                 PIC X(48) VALUE "block".
 01 WS-TAG                 PIC X(112).
 01 WS-IDS.
    05 WS-ID               BINARY-LONG OCCURS 4 TIMES.
 01 WS-COUNT               BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-JSON                PIC X(600).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 8192.
 01 WS-PREC                BINARY-LONG.
 01 WS-FROZEN              BINARY-LONG.
 01 WS-TEMP                FLOAT-LONG.
 01 WS-T2                  FLOAT-LONG.
 01 WS-DIFF                FLOAT-LONG.
 01 WS-NX                  FLOAT-LONG.
 01 WS-NZ                  FLOAT-LONG.
 01 WS-NV                  FLOAT-LONG.
 01 WS-NF                  FLOAT-LONG.
 01 WS-NI                  FLOAT-LONG.
 01 WS-NI2                 FLOAT-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-ONE-SLOT            BINARY-LONG VALUE 1.
 01 WS-LIM                 FLOAT-LONG VALUE 0.15.
 01 WS-MELTS               BINARY-LONG.
 01 WS-KEEPS               BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-ICE-B               BINARY-LONG.
 01 WS-SNOW-B              BINARY-LONG.
 01 WS-SNOW-S              BINARY-LONG.
 01 WS-BIOME               BINARY-LONG.
 01 WS-HIGH                BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE "content/tests/fixtures/std" TO CS-GENERATED-DIR
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS

*>   BIOME-CLIMATE over the NBT of a frozen biome without precipitation and of a warm one with
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE SPACES TO WS-JSON
     STRING '{"attributes": {"minecraft:visual/sky_color": "#78a7ff"}, "carvers": [], "downfall": 0.5,'
         ' "effects": {"water_color": 3750089}, "features": [], "has_precipitation": false,'
         ' "temperature": -0.5, "temperature_modifier": "frozen"}' DELIMITED BY SIZE INTO WS-JSON
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-JSON)) TO WS-LENGTH
     CALL "BIOME-NBT" USING WS-JSON WS-LENGTH PB-BUFFER WS-STATUS
     MOVE 1 TO WS-PREC
     MOVE 0 TO WS-FROZEN WS-TEMP
     CALL "BIOME-CLIMATE" USING PB-BUFFER WS-PREC WS-TEMP WS-FROZEN
     MOVE "35-5§8: BIOME-CLIMATE reads precipitation false and the frozen modifier" TO WS-CASE
     COMPUTE WS-OBS = WS-PREC * 10 + WS-FROZEN
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-5§8: BIOME-CLIMATE reads the temperature -0.5" TO WS-CASE
     COMPUTE WS-OBS = WS-TEMP * 1000
     MOVE -500 TO WS-EXP
     PERFORM ASSERT-N
     CALL "PB-RESET" USING PB-BUFFER
     MOVE SPACES TO WS-JSON
     STRING '{"carvers": [], "downfall": 0.4, "effects": {"water_color": 4159204}, "features": [],'
         ' "has_precipitation": true, "temperature": 0.8}' DELIMITED BY SIZE INTO WS-JSON
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-JSON)) TO WS-LENGTH
     CALL "BIOME-NBT" USING WS-JSON WS-LENGTH PB-BUFFER WS-STATUS
     MOVE 0 TO WS-PREC WS-FROZEN WS-TEMP
     CALL "BIOME-CLIMATE" USING PB-BUFFER WS-PREC WS-TEMP WS-FROZEN
     MOVE "35-5§8: a warm biome has precipitation, no modifier and temperature 0.8" TO WS-CASE
     COMPUTE WS-OBS = WS-PREC * 10000 + WS-FROZEN * 1000 + WS-TEMP * 100
     MOVE 10080 TO WS-EXP
     PERFORM ASSERT-N

*>   the biome table of the test: 0 cold with snow, 1 warm, 2 cold without precipitation, 3 frozen (modifier), 4 0.16 with snow
     MOVE 5 TO CBI-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         MOVE 0 TO CBI-TEMPERATURE(WS-I) CBI-FROZEN(WS-I)
         MOVE 1 TO CBI-PRECIPITATION(WS-I)
     END-PERFORM
     MOVE 0.8 TO CBI-TEMPERATURE(2)
     MOVE 0 TO CBI-PRECIPITATION(3)
     MOVE 1 TO CBI-FROZEN(4)
     MOVE 0.16 TO CBI-TEMPERATURE(5)
*>   up to sea level + 17 the temperature is the base one; above it the adjustment of 33 4.5
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 15
         COMPUTE WS-X = WS-I * 37 - 250
         COMPUTE WS-Z = 300 - WS-I * 53
         MOVE 4 TO WS-BIOME
         MOVE 80 TO WS-Y
         CALL "FR-TEMPERATURE" USING WS-BIOME WS-X WS-Y WS-Z WS-SEA WS-TEMP
         COMPUTE WS-DIFF = FUNCTION ABS(WS-TEMP - 0.16)
         IF WS-DIFF > 0.000001
             ADD 1 TO WS-BAD
         END-IF
         MOVE 130 TO WS-Y
         CALL "FR-TEMPERATURE" USING WS-BIOME WS-X WS-Y WS-Z WS-SEA WS-TEMP
         COMPUTE WS-NX = WS-X / 8
         COMPUTE WS-NZ = WS-Z / 8
         MOVE 2 TO WS-SLOT
         CALL "F351-SIMPLEX-T" USING WS-SLOT WS-NX WS-NZ WS-NV
         COMPUTE WS-T2 = 0.16 - (WS-NV * 8 + 130 - 80) * 0.05 / 40
         COMPUTE WS-DIFF = FUNCTION ABS(WS-TEMP - WS-T2)
         IF WS-DIFF > 0.00001
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "33§4.5: sixteen positions give the base temperature at y 80 and base - (N * 8 + y - 80) * 0.05 / 40 at y 130" TO WS-CASE
     MOVE WS-BAD TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
*>   the frozen biome: 0.2 where the frozen noise and the info noise say so, else its base temperature 0
     MOVE 0 TO WS-MELTS WS-KEEPS WS-BAD
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 79
         COMPUTE WS-X = WS-I * 29 - 1100
         COMPUTE WS-Z = 900 - WS-I * 31
         MOVE 3 TO WS-BIOME
         MOVE 64 TO WS-Y
         CALL "FR-TEMPERATURE" USING WS-BIOME WS-X WS-Y WS-Z WS-SEA WS-TEMP
         MOVE 0 TO WS-NF
         PERFORM VARYING WS-SLOT FROM 1 BY 1 UNTIL WS-SLOT > 3
             EVALUATE WS-SLOT
                 WHEN 1
                     COMPUTE WS-NX = WS-X * 0.05
                     COMPUTE WS-NZ = WS-Z * 0.05
                     MOVE 3 TO WS-J
                 WHEN 2
                     COMPUTE WS-NX = WS-X * 0.025
                     COMPUTE WS-NZ = WS-Z * 0.025
                     MOVE 4 TO WS-J
                 WHEN OTHER
                     COMPUTE WS-NX = WS-X * 0.0125
                     COMPUTE WS-NZ = WS-Z * 0.0125
                     MOVE 5 TO WS-J
             END-EVALUATE
             CALL "F351-SIMPLEX-T" USING WS-J WS-NX WS-NZ WS-NV
             EVALUATE WS-SLOT
                 WHEN 1
                     COMPUTE WS-NF = WS-NF + WS-NV * 0.14285715
                 WHEN 2
                     COMPUTE WS-NF = WS-NF + WS-NV * 0.2857143
                 WHEN OTHER
                     COMPUTE WS-NF = WS-NF + WS-NV * 0.5714286
             END-EVALUATE
         END-PERFORM
         COMPUTE WS-NF = WS-NF * 7
         COMPUTE WS-NX = WS-X * 0.2
         COMPUTE WS-NZ = WS-Z * 0.2
         CALL "F351-SIMPLEX-T" USING WS-ONE-SLOT WS-NX WS-NZ WS-NI
         COMPUTE WS-NX = WS-X * 0.09
         COMPUTE WS-NZ = WS-Z * 0.09
         CALL "F351-SIMPLEX-T" USING WS-ONE-SLOT WS-NX WS-NZ WS-NI2
         IF FUNCTION ABS(WS-NF + WS-NI - 0.3) > 0.0001 AND FUNCTION ABS(WS-NI2 - 0.8) > 0.0001
             IF WS-NF + WS-NI < 0.3 AND WS-NI2 < 0.8
                 ADD 1 TO WS-MELTS
                 COMPUTE WS-DIFF = FUNCTION ABS(WS-TEMP - 0.2)
             ELSE
                 ADD 1 TO WS-KEEPS
                 COMPUTE WS-DIFF = FUNCTION ABS(WS-TEMP)
             END-IF
             IF WS-DIFF > 0.000001
                 ADD 1 TO WS-BAD
             END-IF
         END-IF
     END-PERFORM
     MOVE "10§10 Open question 8: eighty positions of a frozen biome get 0.2 or 0 as the noise rule says" TO WS-CASE
     MOVE WS-BAD TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "10§10 Open question 8: both outcomes of the frozen rule occur in the samples" TO WS-CASE
     IF WS-MELTS > 0 AND WS-KEEPS > 0
         MOVE 1 TO WS-OBS
     ELSE
         MOVE 0 TO WS-OBS
     END-IF
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N

*>   tags, the feature, the chunk
     MOVE "minecraft:cannot_support_snow_layer" TO WS-TAG
     MOVE "ice" TO WS-KEY
     PERFORM WANT-BLOCK
     COMPUTE WS-ID(1) = WS-WANT - 1
     MOVE WS-WANT TO WS-ICE-B
     MOVE "packed_ice" TO WS-KEY
     PERFORM WANT-BLOCK
     COMPUTE WS-ID(2) = WS-WANT - 1
     MOVE 2 TO WS-COUNT
     CALL "TAG-PUT" USING WS-REG WS-TAG WS-COUNT WS-IDS WS-STATUS
     ALLOCATE CE-CHUNK-BYTES CHARACTERS INITIALIZED RETURNING WS-PTR
     CALL "FD-SET-DIR" USING WS-DIR
     CALL "FD-RESET"
     MOVE "minecraft:freeze" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE "35-5§8: the data feature freeze_top_layer compiles (19)" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE 19 TO WS-EXP
     PERFORM ASSERT-N

*>   an empty chunk: nothing happens, nothing is written
     PERFORM NEW-WORLD
     PERFORM RUN-FEATURE
     MOVE "35-5§8: a chunk of air has no top layer: the feature writes nothing and returns true" TO WS-CASE
     COMPUTE WS-OBS = WS-RESULT * 1000 + FL-WRITES
     MOVE 1000 TO WS-EXP
     PERFORM ASSERT-N

*>   the landscape: stone up to y 63 everywhere, then on top
     PERFORM NEW-WORLD
     PERFORM FLOOR
     MOVE "stone" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-STONE
     MOVE "snow" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-SNOW-B
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-SNOW-S
*>   cold biome 0 (x 16 to 19): stone, grass, leaves, a source, flowing water, packed ice
     MOVE 17 TO WS-X
     MOVE 63 TO WS-Y
     MOVE 33 TO WS-Z
     MOVE "grass_block" TO WS-KEY
     MOVE 18 TO WS-X
     PERFORM PUT-AT
     MOVE "oak_leaves" TO WS-KEY
     MOVE 19 TO WS-X
     PERFORM PUT-AT
     MOVE "water" TO WS-KEY
     MOVE 17 TO WS-X
     MOVE 36 TO WS-Z
     PERFORM PUT-AT
     MOVE "level=3" TO WS-PAIRS
     MOVE 18 TO WS-X
     PERFORM PUT-PAIRS
     MOVE "packed_ice" TO WS-KEY
     MOVE 19 TO WS-X
     PERFORM PUT-AT
*>   warm biome 1 (x 20 to 23): grass and a source
     MOVE "grass_block" TO WS-KEY
     MOVE 20 TO WS-X
     MOVE 33 TO WS-Z
     PERFORM PUT-AT
     MOVE "water" TO WS-KEY
     MOVE 20 TO WS-X
     MOVE 36 TO WS-Z
     PERFORM PUT-AT
*>   biome 2 (x 24 to 27, cold, no precipitation): grass and a source
     MOVE "grass_block" TO WS-KEY
     MOVE 24 TO WS-X
     MOVE 33 TO WS-Z
     PERFORM PUT-AT
     MOVE "water" TO WS-KEY
     MOVE 24 TO WS-X
     MOVE 36 TO WS-Z
     PERFORM PUT-AT
*>   biome 4 (x 16 to 19, z 40 to 47: base 0.16): the low ground is warm enough, a tower of stone to y 120 is not
     MOVE 17 TO WS-X
     MOVE 41 TO WS-Z
     MOVE "stone" TO WS-KEY
     PERFORM VARYING WS-Y FROM 64 BY 1 UNTIL WS-Y > 120
         PERFORM PUT-AT
     END-PERFORM
     PERFORM RUN-FEATURE
     MOVE "35-5§8: the feature returns true" TO WS-CASE
     MOVE WS-RESULT TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE 17 TO WS-X
     MOVE 64 TO WS-Y
     MOVE 33 TO WS-Z
     MOVE "snow" TO WS-KEY
     MOVE "35-5§8: a cold column of stone gets a snow layer on top" TO WS-CASE
     PERFORM ASSERT-BLOCK
     MOVE "35-5§8: the snow is the default state, one layer" TO WS-CASE
     MOVE WS-STATE TO WS-OBS
     MOVE WS-SNOW-S TO WS-EXP
     PERFORM ASSERT-N
     MOVE 63 TO WS-Y
     MOVE "stone" TO WS-KEY
     MOVE "35-5§8: and the stone below stays stone (no snowy property)" TO WS-CASE
     PERFORM ASSERT-BLOCK
     MOVE 18 TO WS-X
     MOVE 64 TO WS-Y
     MOVE "snow" TO WS-KEY
     MOVE "35-5§8: snow lies on grass" TO WS-CASE
     PERFORM ASSERT-BLOCK
     MOVE 63 TO WS-Y
     MOVE "grass_block" TO WS-KEY
     MOVE "snowy=true" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-WANT
     CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
     MOVE "35-5§8: the grass below the snow becomes snowy = true" TO WS-CASE
     MOVE WS-STATE TO WS-OBS
     MOVE WS-WANT TO WS-EXP
     PERFORM ASSERT-N
     MOVE 19 TO WS-X
     MOVE 64 TO WS-Y
     MOVE "snow" TO WS-KEY
     MOVE "35-5§8: snow lies on leaves (a collision shape)" TO WS-CASE
     PERFORM ASSERT-BLOCK
     MOVE 17 TO WS-X
     MOVE 36 TO WS-Z
     MOVE 63 TO WS-Y
     MOVE "ice" TO WS-KEY
     MOVE "35-5§8: a source of water in a cold biome freezes" TO WS-CASE
     PERFORM ASSERT-BLOCK
     MOVE 64 TO WS-Y
     MOVE "air" TO WS-KEY
     MOVE "35-5§8: and no snow lies on the new ice (cannot_support_snow_layer)" TO WS-CASE
     PERFORM ASSERT-BLOCK
     MOVE 18 TO WS-X
     MOVE 63 TO WS-Y
     MOVE "water" TO WS-KEY
     MOVE "35-5§8: flowing water does not freeze" TO WS-CASE
     PERFORM ASSERT-BLOCK
     MOVE 64 TO WS-Y
     MOVE "air" TO WS-KEY
     MOVE "35-5§8: and bears no snow" TO WS-CASE
     PERFORM ASSERT-BLOCK
     MOVE 19 TO WS-X
     MOVE "air" TO WS-KEY
     MOVE "35-5§8: packed ice bears no snow" TO WS-CASE
     MOVE 36 TO WS-Z
     PERFORM ASSERT-BLOCK
     MOVE 20 TO WS-X
     MOVE 33 TO WS-Z
     MOVE 64 TO WS-Y
     MOVE "air" TO WS-KEY
     MOVE "35-5§8: a warm biome gets no snow" TO WS-CASE
     PERFORM ASSERT-BLOCK
     MOVE 20 TO WS-X
     MOVE 36 TO WS-Z
     MOVE 63 TO WS-Y
     MOVE "water" TO WS-KEY
     MOVE "35-5§8: and its water stays water" TO WS-CASE
     PERFORM ASSERT-BLOCK
     MOVE 24 TO WS-X
     MOVE 33 TO WS-Z
     MOVE 64 TO WS-Y
     MOVE "air" TO WS-KEY
     MOVE "35-5§8: a cold biome without precipitation has no snow" TO WS-CASE
     PERFORM ASSERT-BLOCK
     MOVE 24 TO WS-X
     MOVE 36 TO WS-Z
     MOVE 63 TO WS-Y
     MOVE "ice" TO WS-KEY
     MOVE "35-5§8: but its water freezes" TO WS-CASE
     PERFORM ASSERT-BLOCK
     MOVE 17 TO WS-X
     MOVE 41 TO WS-Z
     MOVE 121 TO WS-Y
     MOVE "snow" TO WS-KEY
     MOVE "35-5§8: at y 121 the height adjustment makes biome 4 cold enough for snow" TO WS-CASE
     PERFORM ASSERT-BLOCK
     MOVE 16 TO WS-X
     MOVE 41 TO WS-Z
     MOVE 64 TO WS-Y
     MOVE "air" TO WS-KEY
     MOVE "35-5§8: while its low ground (0.16 at y 64) stays free of snow" TO WS-CASE
     PERFORM ASSERT-BLOCK
*>   the frozen biome 3 (x 28 to 31): the water either freezes or not as FR-TEMPERATURE says
     PERFORM NEW-WORLD
     PERFORM FLOOR
     MOVE "water" TO WS-KEY
     MOVE 63 TO WS-Y
     MOVE 0 TO WS-MELTS WS-KEEPS WS-BAD
     PERFORM VARYING WS-X FROM 28 BY 1 UNTIL WS-X > 31
         PERFORM VARYING WS-Z FROM 32 BY 1 UNTIL WS-Z > 47
             PERFORM PUT-AT
         END-PERFORM
     END-PERFORM
     PERFORM RUN-FEATURE
     MOVE 3 TO WS-BIOME
     PERFORM VARYING WS-X FROM 28 BY 1 UNTIL WS-X > 31
         PERFORM VARYING WS-Z FROM 32 BY 1 UNTIL WS-Z > 47
             MOVE 63 TO WS-Y
             CALL "FR-TEMPERATURE" USING WS-BIOME WS-X WS-Y WS-Z WS-SEA WS-TEMP
             CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
             CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
             IF WS-TEMP < WS-LIM
                 ADD 1 TO WS-MELTS
                 IF WS-BLOCK NOT = WS-ICE-B
                     ADD 1 TO WS-BAD
                 END-IF
             ELSE
                 ADD 1 TO WS-KEEPS
                 IF WS-BLOCK = WS-ICE-B
                     ADD 1 TO WS-BAD
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "35-5§8: in a frozen biome each water cell freezes exactly where FR-TEMPERATURE is under 0.15" TO WS-CASE
     MOVE WS-BAD TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-5§8: and the frozen biome has both frozen and open water" TO WS-CASE
     IF WS-MELTS > 0 AND WS-KEEPS > 0
         MOVE 1 TO WS-OBS
     ELSE
         MOVE 0 TO WS-OBS
     END-IF
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N

     MOVE 1 TO FI-GATE
     MOVE "minecraft:freeze_top_layer" TO WS-FTKEY
     CALL "FR-GATE" USING WS-FTKEY WS-COUNT
     MOVE "35-5§8: the gate admits freeze_top_layer" TO WS-CASE
     MOVE WS-COUNT TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
*>   features that cannot be compiled whole: the table is full, or the block table has no ice
     MOVE FD-WA-COUNT TO WS-COUNT
     MOVE FD-MAX-WA TO FD-WA-COUNT
     MOVE "minecraft:freeze2" TO WS-FTKEY
     PERFORM CHECK-BAD
     MOVE WS-COUNT TO FD-WA-COUNT
     MOVE "35-5§8: a full feature table makes the feature unsupported" TO WS-CASE
     PERFORM ASSERT-N
     MOVE CB-BLOCK-COUNT TO WS-COUNT
     MOVE 1 TO CB-BLOCK-COUNT
     MOVE "minecraft:freeze3" TO WS-FTKEY
     PERFORM CHECK-BAD
     MOVE WS-COUNT TO CB-BLOCK-COUNT
     MOVE "35-5§8: a block table without ice or snow makes the feature unsupported" TO WS-CASE
     PERFORM ASSERT-N
     STOP RUN.

 CHECK-BAD.
     MOVE 0 TO FD-BAD
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE -1 TO WS-EXP
     .
*> RUN-FEATURE: the feature at the origin of the chunk (16, -64, 32)
 RUN-FEATURE.
     MOVE 16 TO WS-X
     MOVE -64 TO WS-Y
     MOVE 32 TO WS-Z
     CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-X WS-Y WS-Z WS-RESULT
     .
*> FLOOR: stone from y 40 to 63 over the chunk
 FLOOR.
     MOVE 16 TO WS-X0
     MOVE 31 TO WS-X1
     MOVE 40 TO WS-Y0
     MOVE 63 TO WS-Y1
     MOVE 32 TO WS-Z0
     MOVE 47 TO WS-Z1
     MOVE "stone" TO WS-KEY
     PERFORM FILL-BOX
     .
*> NEW-WORLD: an empty chunk (1, 2); the biome of a cell is: 4 for x 16 to 19 and z 40 to 47, else its quarter of x (0 to 3)
 NEW-WORLD.
     SET ADDRESS OF WS-A TO WS-PTR
     MOVE LOW-VALUES TO WS-A
     CALL "FL-OPEN" USING WS-PTR WS-CX WS-CZ WS-MIN WS-HEIGHT WS-SEA
     SET ADDRESS OF CE-CHUNK TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 1536
         COMPUTE WS-N = FUNCTION MOD(WS-I - 1, 4)
         COMPUTE WS-J = FUNCTION MOD(FUNCTION INTEGER((WS-I - 1) / 4), 4)
         IF WS-N = 0 AND WS-J >= 2
             MOVE 4 TO CE-BIOME(WS-I)
         ELSE
             MOVE WS-N TO CE-BIOME(WS-I)
         END-IF
     END-PERFORM
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     .
 COPY FWTEST.
 END PROGRAM TEST-FEAT-35-5-FREEZE.
 COPY CORETEST.
