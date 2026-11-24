*> Acceptance test of docs/protocol/43-tint-sources.md section 4 (biome blend), V3, V4, V7, V11, V17
*> of section 11: radius 0 is the unaveraged resolver colour, radius r > 0 the box average over
*> (2r + 1)^2 columns at the same y with integer division and opaque alpha, a position in an
*> unloaded chunk reads the plains biome, and the block sources use it (water, tall grass lower
*> half, in-hand grass). The world is the replica of TEST-PLAY (biome 0 everywhere) with
*> biome cells set through TEST-SET-BIOME.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-TINT-43-4.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLTINT.
 COPY CLTINTQ.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-CASE                PIC X(240).
 01 WS-EXPECT              PIC X(8).
 01 WS-COLOUR              BINARY-DOUBLE.
 01 WS-RESOLVER            BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-R1                  COMP-2.
 01 WS-G1                  COMP-2.
 01 WS-B1                  COMP-2.
 01 WS-EDIT                PIC 9.9999.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     MOVE 4 TO TT-BIOMES
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         MOVE 0.8 TO TB-TEMP(WS-I)
         MOVE 0.4 TO TB-DOWN(WS-I)
         MOVE -1 TO TB-GRASS(WS-I) TB-FOLIAGE(WS-I) TB-DRY(WS-I)
         MOVE 0 TO TB-MOD(WS-I)
     END-PERFORM
     MOVE 4282349284 TO TB-WATER(1)
     MOVE 4284578660 TO TB-WATER(2)
     MOVE 2151642852 TO TB-WATER(3)
     MOVE 4282668390 TO TB-GRASS(1)
     MOVE 4279312947 TO TB-GRASS(2)
     MOVE 0 TO TT-PLAINS
     MOVE 4 TO WS-RESOLVER
*>   V4: radius 0 gives the biome's colour exactly, and keeps the alpha the resolver returns.
     MOVE 8 TO WS-X
     MOVE 10 TO WS-Y
     MOVE 8 TO WS-Z
     MOVE 0 TO WS-R
     CALL "TINT-AVERAGE" USING CLIENT-STATE WS-RESOLVER WS-X WS-Y WS-Z WS-R WS-COLOUR
     MOVE "acceptance US11 43§4 Biome blend: V4 radius 0 in plains" TO WS-CASE
     MOVE "FF3F76E4" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT WS-COLOUR
     MOVE 1 TO WS-B
     MOVE 0 TO WS-X
     MOVE 0 TO WS-Z
     CALL "TEST-SET-BIOME" USING CLIENT-STATE WS-X WS-Y WS-Z WS-B
*>   V17: radius 7 is 15 x 15 = 225 columns: 9 swamp columns (x 1 to 3, z 1 to 3) and 216 plains.
     MOVE 8 TO WS-X
     MOVE 8 TO WS-Z
     MOVE 7 TO WS-R
     CALL "TINT-AVERAGE" USING CLIENT-STATE WS-RESOLVER WS-X WS-Y WS-Z WS-R WS-COLOUR
     MOVE "acceptance US11 43§4 Biome blend: V17 radius 7 divides by 225" TO WS-CASE
     MOVE "FF4076DE" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT WS-COLOUR
*>   V3: radius 1 at (4, y, 4): the column x 3 of the cells x 0 to 3 is swamp for z 3 to 5 (3 of 9).
     MOVE 0 TO WS-X
     MOVE 4 TO WS-Z
     CALL "TEST-SET-BIOME" USING CLIENT-STATE WS-X WS-Y WS-Z WS-B
     MOVE 4 TO WS-X
     MOVE 1 TO WS-R
     CALL "TINT-AVERAGE" USING CLIENT-STATE WS-RESOLVER WS-X WS-Y WS-Z WS-R WS-COLOUR
     MOVE "acceptance US11 43§4 Biome blend: V3 radius 1 sums 669 1077 1668 over 9" TO WS-CASE
     MOVE "FF4A77B9" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT WS-COLOUR
*>   The box is taken at the same y: one cell above holds only plains.
     MOVE 20 TO WS-Y
     CALL "TINT-AVERAGE" USING CLIENT-STATE WS-RESOLVER WS-X WS-Y WS-Z WS-R WS-COLOUR
     MOVE "acceptance US11 43§4 Biome blend: the box stays at the query y" TO WS-CASE
     MOVE "FF3F76E4" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT WS-COLOUR
     MOVE 10 TO WS-Y
*>   An unloaded chunk reads the plains biome.
     MOVE 1000 TO WS-X
     MOVE 1000 TO WS-Z
     MOVE 0 TO WS-R
     CALL "TINT-AVERAGE" USING CLIENT-STATE WS-RESOLVER WS-X WS-Y WS-Z WS-R WS-COLOUR
     MOVE "acceptance US11 43§4 Biome blend: no chunk reads the plains biome" TO WS-CASE
     MOVE "FF3F76E4" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT WS-COLOUR
*>   Alpha: radius 0 keeps the resolver's alpha, a blend is opaque.
     MOVE 2 TO WS-B
     MOVE 24 TO WS-X
     MOVE 24 TO WS-Z
     CALL "TEST-SET-BIOME" USING CLIENT-STATE WS-X WS-Y WS-Z WS-B
     CALL "TINT-AVERAGE" USING CLIENT-STATE WS-RESOLVER WS-X WS-Y WS-Z WS-R WS-COLOUR
     MOVE "acceptance US11 43§4 Biome blend: radius 0 keeps alpha 80" TO WS-CASE
     MOVE "803F76E4" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT WS-COLOUR
     MOVE 1 TO WS-R
     MOVE 25 TO WS-X
     MOVE 25 TO WS-Z
     CALL "TINT-AVERAGE" USING CLIENT-STATE WS-RESOLVER WS-X WS-Y WS-Z WS-R WS-COLOUR
     MOVE "acceptance US11 43§4 Biome blend: a blend is opaque" TO WS-CASE
     MOVE "FF3F76E4" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT WS-COLOUR
     MOVE 8 TO WS-X
     MOVE 8 TO WS-Z
     MOVE 1 TO WS-B
     CALL "TEST-SET-BIOME" USING CLIENT-STATE WS-X WS-Y WS-Z WS-B
*>   Block sources: water in a cauldron in the world uses the average (V3 again), waterParticles
*>   colours only the terrain particle; V11: 0.6 x 63 / 255 = 0.1482.
     MOVE "water_cauldron" TO TQ-NAME
     MOVE 0 TO TQ-INDEX
     MOVE 1 TO TQ-MODE
     MOVE 4 TO TQ-X
     MOVE 10 TO TQ-Y
     MOVE 4 TO TQ-Z
     MOVE 1 TO TQ-RADIUS
     CALL "TINT-BLOCK-COLOR" USING CLIENT-STATE TINT-QUERY
     MOVE "acceptance US11 43§4 Biome blend: water_cauldron in world blends" TO WS-CASE
     MOVE "FF4A77B9" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT TQ-COLOUR
     MOVE "water" TO TQ-NAME
     MOVE 8 TO TQ-X
     MOVE 8 TO TQ-Z
     MOVE 0 TO TQ-RADIUS
     CALL "TINT-BLOCK-COLOR" USING CLIENT-STATE TINT-QUERY
     MOVE "acceptance US11 43§4 Biome blend: water block in world is white" TO WS-CASE
     MOVE "FFFFFFFF" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT TQ-COLOUR
     MOVE 2 TO TQ-MODE
     CALL "TINT-PARTICLE-RGB" USING CLIENT-STATE TINT-QUERY WS-R1 WS-G1 WS-B1
     COMPUTE WS-EDIT ROUNDED = WS-R1
     MOVE "acceptance US11 43§4 Biome blend: V11 water particle red 0.6 x 97 / 255 (swamp)" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "0.2282" TO TL-EXPECTED
     MOVE WS-EDIT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   V7: the upper half of tall grass at y 12 reads the grass colour of y 11 (the swamp override).
     MOVE "tall_grass" TO TQ-NAME
     MOVE 1 TO TQ-MODE
     MOVE 12 TO TQ-Y
     MOVE 1 TO TQ-HALF
     CALL "TINT-BLOCK-COLOR" USING CLIENT-STATE TINT-QUERY
     MOVE "acceptance US11 43§4 Biome blend: V7 tall grass upper reads one block down" TO WS-CASE
     MOVE "FF112233" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT TQ-COLOUR
     MOVE 0 TO TQ-HALF
     CALL "TINT-BLOCK-COLOR" USING CLIENT-STATE TINT-QUERY
     MOVE "acceptance US11 43§4 Biome blend: tall grass lower half reads its own position"
         TO WS-CASE
     MOVE "FF445566" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT TQ-COLOUR
*>   The other biome kinds of the world: grass, sugar cane, foliage, dry foliage, and their particles.
     MOVE "fern" TO TQ-NAME
     MOVE 11 TO TQ-Y
     CALL "TINT-BLOCK-COLOR" USING CLIENT-STATE TINT-QUERY
     MOVE "acceptance US11 43§4 Biome blend: fern in world uses grass" TO WS-CASE
     MOVE "FF112233" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT TQ-COLOUR
     MOVE "sugar_cane" TO TQ-NAME
     CALL "TINT-BLOCK-COLOR" USING CLIENT-STATE TINT-QUERY
     MOVE "acceptance US11 43§4 Biome blend: sugar cane in world uses grass" TO WS-CASE
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT TQ-COLOUR
     MOVE "grass_block" TO TQ-NAME
     CALL "TINT-BLOCK-COLOR" USING CLIENT-STATE TINT-QUERY
     MOVE "acceptance US11 43§4 Biome blend: grass block in world uses grass" TO WS-CASE
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT TQ-COLOUR
     MOVE 2 TO TQ-MODE
     MOVE "fern" TO TQ-NAME
     CALL "TINT-BLOCK-COLOR" USING CLIENT-STATE TINT-QUERY
     MOVE "acceptance US11 43§4 Biome blend: fern terrain particle uses grass" TO WS-CASE
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT TQ-COLOUR
     MOVE 1 TO TQ-MODE
     MOVE "oak_leaves" TO TQ-NAME
     MOVE 4282955032 TO TB-FOLIAGE(2)
     CALL "TINT-BLOCK-COLOR" USING CLIENT-STATE TINT-QUERY
     MOVE "acceptance US11 43§4 Biome blend: oak leaves in world use foliage" TO WS-CASE
     MOVE "FF48B518" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT TQ-COLOUR
     MOVE "leaf_litter" TO TQ-NAME
     MOVE 4284234802 TO TB-DRY(2)
     CALL "TINT-BLOCK-COLOR" USING CLIENT-STATE TINT-QUERY
     MOVE "acceptance US11 43§4 Biome blend: leaf litter in world uses dry foliage" TO WS-CASE
     MOVE "FF5C3C32" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT TQ-COLOUR
     MOVE "fern" TO TQ-NAME
     MOVE 0 TO TQ-MODE
     CALL "TINT-BLOCK-COLOR" USING CLIENT-STATE TINT-QUERY
     MOVE "acceptance US11 43§4 Biome blend: fern in hand uses the default colour (no pixel yet)" TO WS-CASE
     MOVE "00000000" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT TQ-COLOUR
*>   In hand the grass sources use the colormap at (0.5, 1.0): pixel (127, 127).
     COMPUTE WS-J = 127 * 256 + 127 + 1
     MOVE 4286365035 TO TT-MAP-GRASS(WS-J)
     MOVE "grass_block" TO TQ-NAME
     MOVE 0 TO TQ-MODE
     CALL "TINT-BLOCK-COLOR" USING CLIENT-STATE TINT-QUERY
     MOVE "acceptance US11 43§4 Biome blend: grass block in hand uses the default colour" TO WS-CASE
     MOVE "FF7CBD6B" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT TQ-COLOUR
     MOVE "tall_grass" TO TQ-NAME
     CALL "TINT-BLOCK-COLOR" USING CLIENT-STATE TINT-QUERY
     MOVE "acceptance US11 43§4 Biome blend: tall grass in hand uses the default colour" TO WS-CASE
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT TQ-COLOUR
     MOVE "fern" TO TQ-NAME
     CALL "TINT-BLOCK-COLOR" USING CLIENT-STATE TINT-QUERY
     MOVE "acceptance US11 43§4 Biome blend: fern in hand uses the default colour" TO WS-CASE
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT TQ-COLOUR
     STOP RUN.
 END PROGRAM TEST-TINT-43-4.
 COPY CLTEST.
 COPY TINTTEST.
