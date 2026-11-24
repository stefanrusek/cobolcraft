*> Implementation test of the fluid mesh (client/src/mesher-fluid.cob, MESH-FLUID, called by MESH-SECTION; docs/protocol/29a-fluids.md
*> section 10): a cell whose state is water or lava (ST-FLUID, ST-LEVEL of the state tables) draws its own quads, not baked ones.
*> Face selection (10.1: no face between two cells of one fluid, none against an opaque neighbour, the top face when the fluid above is
*> not the same), corner heights (10.2: E10 isolated source 0.7407, pool source 0.8889, same fluid above 1.0), geometry (10.3: top
*> vertices 0.001 below the corner height, still sprite for no flow, flowing sprite turned by the flow vector otherwise), tint (water the
*> biome water colour, lava white), light (max of the cell and the cell above, per face factor) and the layer (water translucent, lava
*> opaque).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MESHER-FLUID.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CELLS.
 COPY TESTLIB.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ROW-B               BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 01 WS-SECTION             BINARY-LONG VALUE 1.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-X                   FLOAT-SHORT.
 01 WS-Y                   FLOAT-SHORT.
 01 WS-Z                   FLOAT-SHORT.
 01 WS-FOUND               BINARY-LONG.
 01 WS-B                   FLOAT-SHORT.
 01 WS-U                   FLOAT-SHORT.
 01 WS-V                   FLOAT-SHORT.
 01 WS-SKY                 FLOAT-SHORT.
 01 WS-R                   FLOAT-SHORT.
 01 WS-G                   FLOAT-SHORT.
 01 WS-BLUE                FLOAT-SHORT.
 01 WS-E                   PIC 9.99.
 01 WS-E1                  PIC Z(9)9.
 01 WS-E2                  PIC Z(9)9.
 01 WS-E3                  PIC Z(9)9.
 01 WS-EXPECT-U            FLOAT-SHORT.
 01 WS-EXPECT-V            FLOAT-SHORT.
 01 WS-WATER               BINARY-DOUBLE.
 01 WS-GRASS               BINARY-DOUBLE.
 01 WS-FOLIAGE             BINARY-DOUBLE.
 01 WS-DRY                 BINARY-DOUBLE VALUE -1.
 01 WS-MOD                 PIC X(16) VALUE "none".
 01 WS-T                   COMP-2.
 01 WS-D                   COMP-2.
 01 WS-BIOME               BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LY                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-LL                  BINARY-LONG.
 01 WS-TEXT                PIC X(80).
 01 WS-TEXT-2              PIC X(120).
 01 WS-LEN                 BINARY-LONG.
 01 WS-STILL               BINARY-LONG.
 01 WS-FLOW                BINARY-LONG.
 01 WS-LAVA                BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "PACK-STACK-INIT" USING CLIENT-STATE
     CALL "ATLAS-BUILD" USING CLIENT-STATE
     CALL "MODELS-BAKE" USING CLIENT-STATE
     MOVE 256 TO PL-HEIGHT
     MOVE 1000 TO SK-U
     CALL "STATE-TABLES-ENSURE" USING CLIENT-STATE
*>   The sprites of the fluids, as a pack would give them (the built-in pack has none): each 16 x 16, water still translucent.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         ADD 1 TO AT-SPRITE-COUNT
         MOVE AT-SPRITE-COUNT TO WS-N
         MOVE SPACES TO AT-NAME(WS-N)
         EVALUATE WS-I
             WHEN 1
                 MOVE "minecraft:block/water_still" TO AT-NAME(WS-N)
                 MOVE 1 TO AT-TRANSLUCENT(WS-N)
                 MOVE WS-N TO WS-STILL
             WHEN 2
                 MOVE "minecraft:block/water_flow" TO AT-NAME(WS-N)
                 MOVE 1 TO AT-TRANSLUCENT(WS-N)
                 MOVE WS-N TO WS-FLOW
             WHEN 3
                 MOVE "minecraft:block/water_overlay" TO AT-NAME(WS-N)
                 MOVE 1 TO AT-TRANSLUCENT(WS-N)
             WHEN 4
                 MOVE "minecraft:block/lava_still" TO AT-NAME(WS-N)
                 MOVE 0 TO AT-TRANSLUCENT(WS-N)
                 MOVE WS-N TO WS-LAVA
             WHEN OTHER
                 MOVE "minecraft:block/lava_flow" TO AT-NAME(WS-N)
                 MOVE 0 TO AT-TRANSLUCENT(WS-N)
         END-EVALUATE
         MOVE FUNCTION LENGTH(FUNCTION TRIM(AT-NAME(WS-N))) TO AT-NAME-LENGTH(WS-N)
         COMPUTE AT-X(WS-N) = 2 * WS-I
         MOVE 0 TO AT-Y(WS-N)
         MOVE 16 TO AT-SW(WS-N) AT-SH(WS-N)
     END-PERFORM
*>   States 310 water source, 311 flowing water level 3 (amount 5), 312 lava source (rows are state + 1), 313 kelp-like water (level 3).
     MOVE 1 TO ST-FLUID(311) ST-FLUID(312)
     MOVE 3 TO ST-FLUID(314)
     MOVE 2 TO ST-FLUID(313)
     MOVE 0 TO ST-LEVEL(311) ST-LEVEL(313)
     MOVE 3 TO ST-LEVEL(312) ST-LEVEL(314)
     MOVE 0 TO ST-OPAQUE(311) ST-OPAQUE(312) ST-OPAQUE(313) ST-OPAQUE(314)
     MOVE 0.6 TO WS-T
     MOVE 0.4 TO WS-D
     MOVE 4282349284 TO WS-WATER
     MOVE 4283404090 TO WS-GRASS
     MOVE 4284119852 TO WS-FOLIAGE
     MOVE 0 TO WS-BIOME
     CALL "TINT-BIOME-SET" USING WS-BIOME WS-T WS-D WS-WATER WS-GRASS WS-FOLIAGE WS-DRY WS-MOD
     CALL "WORLD-ROW-NEW" USING CLIENT-STATE WS-ZERO WS-ZERO2 WS-ROW
     SET ADDRESS OF CE-CHUNK TO WR-ADDR(WS-ROW)
     MOVE ALL X"FF" TO CE-SKYS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 1024
         MOVE 0 TO CE-BIOME(WS-I)
     END-PERFORM
*>   A stone floor (greystone, state 2) at y 1 over x 0 to 15, z 0 to 15 except the lava square; then:
*>   A: an isolated water source (12, 2, 12); B: a 3 x 3 pool (4..6, 2, 4..6); C: two sources one above the other (9, 2, 9) (9, 3, 9);
*>   D: a source (13, 2, 2) beside flowing level 3 (14, 2, 2); E: a lava source (2, 2, 12) with block light 10 (12 above it).
     PERFORM VARYING WS-N FROM 0 BY 1 UNTIL WS-N > 255
         MOVE 2 TO CE-STATE(256 + WS-N + 1)
     END-PERFORM
     MOVE 310 TO CE-STATE(2 * 256 + 12 * 16 + 12 + 1)
*>   M: a glass-like block (state 314, overlay 1) south of the isolated source: its south face takes the overlay sprite.
     MOVE 1 TO ST-OVERLAY(315)
     MOVE 0 TO ST-OPAQUE(315)
     MOVE 314 TO CE-STATE(2 * 256 + 13 * 16 + 12 + 1)
     PERFORM VARYING WS-I FROM 4 BY 1 UNTIL WS-I > 6
         PERFORM VARYING WS-N FROM 4 BY 1 UNTIL WS-N > 6
             MOVE 310 TO CE-STATE(2 * 256 + WS-N * 16 + WS-I + 1)
         END-PERFORM
     END-PERFORM
     MOVE 310 TO CE-STATE(2 * 256 + 9 * 16 + 9 + 1)
     MOVE 310 TO CE-STATE(3 * 256 + 9 * 16 + 9 + 1)
     MOVE 310 TO CE-STATE(2 * 256 + 2 * 16 + 13 + 1)
     MOVE 311 TO CE-STATE(2 * 256 + 2 * 16 + 14 + 1)
     MOVE 312 TO CE-STATE(2 * 256 + 12 * 16 + 2 + 1)
     MOVE 1 TO WS-K
     MOVE 2 TO WS-LX
     MOVE 2 TO WS-LY
     MOVE 12 TO WS-LZ
     MOVE 10 TO WS-LL
     CALL "LIGHT-SET" USING WR-ADDR(WS-ROW) WS-K WS-LY WS-LX WS-LZ WS-LL
     MOVE 3 TO WS-LY
     MOVE 12 TO WS-LL
     CALL "LIGHT-SET" USING WR-ADDR(WS-ROW) WS-K WS-LY WS-LX WS-LZ WS-LL
*>   F: kind 3 cells (7, 2, 12) alone and (5, 2, 10) (5, 2, 11) (5, 3, 11) together; G: a water source (3, 2, 12) beside the lava, with stone at (3, 2, 11);
*>   H: a waterfall edge: a pillar (8, 2, 14), a source (8, 3, 14), kind 3 water below its east neighbour (9, 2, 14); I: a ceiling:
*>   a source (12, 2, 7) with sources around it, stone above it and water above the four; J: the row's border cells (15, 2, 5),
*>   (0, 2, 0) and the row east of it (0, 2, 5); K: a source at the bottom (3, 0, 3) and one at the top (3, 15, 3) (height 16).
     MOVE 313 TO CE-STATE(2 * 256 + 12 * 16 + 7 + 1) CE-STATE(2 * 256 + 10 * 16 + 5 + 1) CE-STATE(2 * 256 + 11 * 16 + 5 + 1)
         CE-STATE(3 * 256 + 11 * 16 + 5 + 1)
     MOVE 310 TO CE-STATE(2 * 256 + 12 * 16 + 3 + 1)
     MOVE 2 TO CE-STATE(2 * 256 + 11 * 16 + 3 + 1)
     MOVE 2 TO CE-STATE(2 * 256 + 14 * 16 + 8 + 1)
     MOVE 310 TO CE-STATE(3 * 256 + 14 * 16 + 8 + 1)
     MOVE 313 TO CE-STATE(2 * 256 + 14 * 16 + 9 + 1)
     MOVE 310 TO CE-STATE(2 * 256 + 7 * 16 + 12 + 1) CE-STATE(2 * 256 + 6 * 16 + 12 + 1) CE-STATE(2 * 256 + 8 * 16 + 12 + 1)
         CE-STATE(2 * 256 + 7 * 16 + 13 + 1) CE-STATE(2 * 256 + 7 * 16 + 11 + 1)
     MOVE 2 TO CE-STATE(3 * 256 + 7 * 16 + 12 + 1)
     MOVE 310 TO CE-STATE(3 * 256 + 6 * 16 + 12 + 1) CE-STATE(3 * 256 + 8 * 16 + 12 + 1) CE-STATE(3 * 256 + 7 * 16 + 13 + 1)
         CE-STATE(3 * 256 + 7 * 16 + 11 + 1)
     MOVE 310 TO CE-STATE(2 * 256 + 5 * 16 + 15 + 1) CE-STATE(2 * 256 + 0 * 16 + 0 + 1)
     MOVE 310 TO CE-STATE(0 * 256 + 3 * 16 + 3 + 1) CE-STATE(15 * 256 + 3 * 16 + 3 + 1)
*>   L: a well, a source (2, 3, 9) with stone on its four sides and below and water above (nothing to draw); a source (6, 2, 15) at the
*>   south border.
     MOVE 2 TO CE-STATE(2 * 256 + 9 * 16 + 2 + 1) CE-STATE(3 * 256 + 8 * 16 + 2 + 1) CE-STATE(3 * 256 + 10 * 16 + 2 + 1)
         CE-STATE(3 * 256 + 9 * 16 + 3 + 1) CE-STATE(3 * 256 + 9 * 16 + 1 + 1)
     MOVE 310 TO CE-STATE(3 * 256 + 9 * 16 + 2 + 1) CE-STATE(4 * 256 + 9 * 16 + 2 + 1) CE-STATE(2 * 256 + 15 * 16 + 6 + 1)
     MOVE 1 TO WS-ZERO2
     MOVE 0 TO WS-K
     CALL "WORLD-ROW-NEW" USING CLIENT-STATE WS-ZERO2 WS-K WS-ROW-B
     SET ADDRESS OF CE-CHUNK TO WR-ADDR(WS-ROW-B)
     MOVE ALL X"FF" TO CE-SKYS
     MOVE 310 TO CE-STATE(2 * 256 + 5 * 16 + 0 + 1)
     SET ADDRESS OF CE-CHUNK TO WR-ADDR(WS-ROW)
     MOVE 16 TO PL-HEIGHT
     CALL "MESH-SECTION" USING CLIENT-STATE WS-ROW WS-SECTION

*>   A: face selection and geometry of an isolated source.
     MOVE "mesher fluid an isolated water source over stone draws a top face and four sides (no bottom face against the opaque "
         & "floor): 5 quads in the translucent mesh" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 30 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     PERFORM FIND-ISOLATED-COUNT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "mesher fluid the top of an isolated source is at 0.7407 - 0.001 (corner average of 10.2 E10), the floor face absent"
         TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "found none" TO TL-EXPECTED
     MOVE 12.5 TO WS-X
     MOVE 2.7397 TO WS-Y
     MOVE 12.5 TO WS-Z
     PERFORM FIND-WATER
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE 12.5 TO WS-X
     MOVE 2.0 TO WS-Y
     MOVE 12.5 TO WS-Z
     PERFORM FIND-WATER
     STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-TEXT) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "mesher fluid the still sprite covers the top face of a source with no flow: the first vertex is the sprite's top-left"
         TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     MOVE 12.5 TO WS-X
     MOVE 2.7397 TO WS-Y
     MOVE 12.5 TO WS-Z
     PERFORM FIND-WATER
     COMPUTE WS-EXPECT-U = AT-X(WS-STILL) / AT-W
     COMPUTE WS-EXPECT-V = AT-Y(WS-STILL) / AT-H
     IF FUNCTION ABS(WS-U - WS-EXPECT-U) < 0.0001 AND FUNCTION ABS(WS-V - WS-EXPECT-V) < 0.0001
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "mesher fluid a side face of the source runs from the floor up to 0.7407 and takes the flowing sprite: the north face "
         & "centre is (12.5, 2.3704, 12.001)" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "found" TO TL-EXPECTED
     MOVE 12.5 TO WS-X
     MOVE 2.3704 TO WS-Y
     MOVE 12.001 TO WS-Z
     PERFORM FIND-WATER
     MOVE SPACES TO TL-OBSERVED
     IF WS-FOUND = 1
         MOVE "found" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Tint: the biome's water colour.
     MOVE "mesher fluid water takes the biome water colour (#3F76E4, 63 118 228) on every face, lava stays white" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "63 118 228 | 255 255 255" TO TL-EXPECTED
     MOVE 12.5 TO WS-X
     MOVE 2.7397 TO WS-Y
     MOVE 12.5 TO WS-Z
     PERFORM FIND-WATER
     PERFORM RGB-TEXT
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE 2.5 TO WS-X
     MOVE 2.7397 TO WS-Y
     MOVE 12.5 TO WS-Z
     CALL "TEST-MESH-VERTEX" USING WR-OP-ADDR(WS-ROW, 1) WR-OP-COUNT(WS-ROW, 1) WS-X WS-Y WS-Z
         WS-FOUND WS-B WS-U WS-V WS-SKY WS-R WS-G WS-BLUE
     PERFORM RGB-TEXT
     MOVE SPACES TO WS-TEXT-2
     STRING FUNCTION TRIM(TL-OBSERVED) " | " FUNCTION TRIM(WS-TEXT) DELIMITED BY SIZE INTO WS-TEXT-2
     MOVE WS-TEXT-2 TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   B: a pool.
     MOVE "mesher fluid the centre source of a 3 x 3 pool draws only its top face, at 0.8889 - 0.001 (no face against the same "
         & "fluid)" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "found none none" TO TL-EXPECTED
     MOVE 5.5 TO WS-X
     MOVE 2.8879 TO WS-Y
     MOVE 5.5 TO WS-Z
     PERFORM FIND-WATER
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE 5.999 TO WS-X
     MOVE 2.4444 TO WS-Y
     MOVE 5.5 TO WS-Z
     PERFORM FIND-WATER
     STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-TEXT) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE 5.5 TO WS-X
     MOVE 2.0 TO WS-Y
     MOVE 5.5 TO WS-Z
     PERFORM FIND-WATER
     STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-TEXT) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   C: a source under the same fluid is full height and has no top face; the upper source has its own top.
     MOVE "mesher fluid a source under water has no top face and its side faces reach 1.0 (the north face centre y 2.5); the "
         & "source above has its top at 3.7397" TO TL-CASE
     MOVE "found none found" TO TL-EXPECTED
     MOVE 9.5 TO WS-X
     MOVE 2.5 TO WS-Y
     MOVE 9.001 TO WS-Z
     PERFORM FIND-WATER
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE 9.5 TO WS-X
     MOVE 2.999 TO WS-Y
     MOVE 9.5 TO WS-Z
     PERFORM FIND-WATER
     STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-TEXT) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE 9.5 TO WS-X
     MOVE 3.7397 TO WS-Y
     MOVE 9.5 TO WS-Z
     PERFORM FIND-WATER
     STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-TEXT) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   D: a flowing cell takes the flowing sprite turned by its flow (east, away from the source: angle -pi/2, first vertex (0.75, 0.25)).
     MOVE "mesher fluid the top of flowing level 3 beside a source flows east: its first vertex is at (0.75, 0.25) of the flowing "
         & "sprite, and its top at (mean of NW 0.7265 and SE 0.1852) - 0.001" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     MOVE 14.5 TO WS-X
     MOVE 2.4548 TO WS-Y
     MOVE 2.5 TO WS-Z
     PERFORM FIND-WATER
     COMPUTE WS-EXPECT-U = (AT-X(WS-FLOW) + 0.75 * 16) / AT-W
     COMPUTE WS-EXPECT-V = (AT-Y(WS-FLOW) + 0.25 * 16) / AT-H
     IF WS-FOUND = 1 AND FUNCTION ABS(WS-U - WS-EXPECT-U) < 0.0001
             AND FUNCTION ABS(WS-V - WS-EXPECT-V) < 0.0001
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   E: lava goes to the opaque mesh and is lit by the larger of its cell and the cell above, times the face factor.
     MOVE "mesher fluid a lava source lit 10 with 12 above: top face 12/15 = 0.80, north face 0.8 x 12/15 = 0.64, in the opaque mesh"
         TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "0.80 0.64" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE 2.5 TO WS-X
     MOVE 2.7397 TO WS-Y
     MOVE 12.5 TO WS-Z
     CALL "TEST-MESH-VERTEX" USING WR-OP-ADDR(WS-ROW, 1) WR-OP-COUNT(WS-ROW, 1) WS-X WS-Y WS-Z
         WS-FOUND WS-B WS-U WS-V WS-SKY WS-R WS-G WS-BLUE
     COMPUTE WS-E ROUNDED = WS-B
     MOVE WS-E TO TL-OBSERVED
     MOVE 2.5 TO WS-X
     MOVE 2.3704 TO WS-Y
     MOVE 12.001 TO WS-Z
     CALL "TEST-MESH-VERTEX" USING WR-OP-ADDR(WS-ROW, 1) WR-OP-COUNT(WS-ROW, 1) WS-X WS-Y WS-Z
         WS-FOUND WS-B WS-U WS-V WS-SKY WS-R WS-G WS-BLUE
     COMPUTE WS-E ROUNDED = WS-B
     STRING FUNCTION TRIM(TL-OBSERVED) " " WS-E DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   F: a water block with a model still draws its water (here the same quads as water); G: lava beside a source does not move it, an
*>   opaque neighbour neither: still sprite, top at the mean of NW 0.8081 and SE 0.7407 less 0.001.
     MOVE "mesher fluid a kind 3 cell (kelp, seagrass, bubble column) draws water and keeps its model; water beside lava and "
         & "stone has no flow and uses the still sprite" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "found found 1" TO TL-EXPECTED
     MOVE 7.5 TO WS-X
     MOVE 2.1842 TO WS-Y
     MOVE 12.5 TO WS-Z
     PERFORM FIND-WATER
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE 3.5 TO WS-X
     MOVE 2.7734 TO WS-Y
     MOVE 12.5 TO WS-Z
     PERFORM FIND-WATER
     COMPUTE WS-EXPECT-U = AT-X(WS-STILL) / AT-W
     MOVE 0 TO WS-N
     IF FUNCTION ABS(WS-U - WS-EXPECT-U) < 0.0001
         MOVE 1 TO WS-N
     END-IF
     MOVE WS-N TO WS-E1
     MOVE SPACES TO WS-TEXT-2
     STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-TEXT) " " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO WS-TEXT-2
     MOVE WS-TEXT-2 TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   H: the waterfall edge flows toward the drop (east): flowing sprite, first vertex (0.75, 0.25).
     MOVE "mesher fluid a source whose empty neighbour has water below flows toward it (east): first vertex (0.75, 0.25) of "
         & "the flowing sprite" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     MOVE 8.5 TO WS-X
     MOVE 3.7397 TO WS-Y
     MOVE 14.5 TO WS-Z
     PERFORM FIND-WATER
     COMPUTE WS-EXPECT-U = (AT-X(WS-FLOW) + 0.75 * 16) / AT-W
     COMPUTE WS-EXPECT-V = (AT-Y(WS-FLOW) + 0.25 * 16) / AT-H
     IF WS-FOUND = 1 AND FUNCTION ABS(WS-U - WS-EXPECT-U) < 0.0001
             AND FUNCTION ABS(WS-V - WS-EXPECT-V) < 0.0001
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   I: a block above the centre of four sources whose neighbours have water above: every corner is full and the top is hidden.
     MOVE "mesher fluid a source under a block whose four neighbours have water above has full corners and no top face "
         & "(the top would be at 2.999)" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "none" TO TL-EXPECTED
     MOVE 12.5 TO WS-X
     MOVE 2.999 TO WS-Y
     MOVE 7.5 TO WS-Z
     PERFORM FIND-WATER
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   J: at the border of the row: a source beside water of the next row has no east face; one at a corner with no row beside it has
*>   all its faces (neighbours not loaded are void); a source at the bottom of the world has a bottom face (void below); one at the
*>   top has its top face (void above).
     MOVE "mesher fluid a source at the east border beside water of the next row has no east face; at a corner with no row beside "
         & "it all five faces; at the world's bottom and top the faces towards the void" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "none found found found found" TO TL-EXPECTED
     MOVE 15.999 TO WS-X
     MOVE 2.4444 TO WS-Y
     MOVE 5.5 TO WS-Z
     PERFORM FIND-WATER
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE 0.001 TO WS-X
     MOVE 2.3704 TO WS-Y
     MOVE 0.5 TO WS-Z
     PERFORM FIND-WATER
     STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-TEXT) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE 0.5 TO WS-X
     MOVE 2.3704 TO WS-Y
     MOVE 0.001 TO WS-Z
     PERFORM FIND-WATER
     STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-TEXT) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE 3.5 TO WS-X
     MOVE 0.001 TO WS-Y
     MOVE 3.5 TO WS-Z
     PERFORM FIND-WATER
     STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-TEXT) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE 3.5 TO WS-X
     MOVE 15.7397 TO WS-Y
     MOVE 3.5 TO WS-Z
     PERFORM FIND-WATER
     STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-TEXT) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "mesher fluid a source enclosed by stone and water has no face; one at the south border beside no row has its south face"
         TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "none found" TO TL-EXPECTED
     MOVE 2.5 TO WS-X
     MOVE 3.4444 TO WS-Y
     MOVE 8.001 TO WS-Z
     PERFORM FIND-WATER
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE 6.5 TO WS-X
     MOVE 2.3704 TO WS-Y
     MOVE 15.999 TO WS-Z
     PERFORM FIND-WATER
     STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-TEXT) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "mesher fluid the face beside a glass-like block takes the overlay sprite (its first vertex at the sprite's left), a face "
         & "beside air the flowing sprite" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     MOVE 12.5 TO WS-X
     MOVE 2.3704 TO WS-Y
     MOVE 12.999 TO WS-Z
     PERFORM FIND-WATER
     COMPUTE WS-N = WS-STILL + 2
     COMPUTE WS-EXPECT-U = AT-X(WS-N) / AT-W
     IF WS-FOUND = 1 AND FUNCTION ABS(WS-U - WS-EXPECT-U) < 0.0001
         MOVE 12.001 TO WS-Z
         PERFORM FIND-WATER
         COMPUTE WS-N = WS-STILL + 1
         COMPUTE WS-EXPECT-U = AT-X(WS-N) / AT-W
         IF WS-FOUND = 1 AND FUNCTION ABS(WS-U - WS-EXPECT-U) < 0.0001
             MOVE 1 TO TL-OBSERVED-N
         END-IF
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The sprites are found again when the atlas changes: with the still sprite renamed away, the top of the isolated source takes
*>   the missing texture (sprite 1).
     MOVE "gone" TO AT-NAME(WS-STILL)
     MOVE 4 TO AT-NAME-LENGTH(WS-STILL)
     CALL "MESH-SECTION" USING CLIENT-STATE WS-ROW WS-SECTION
     MOVE "mesher fluid a sprite that is no longer in the atlas is looked up again and the missing texture (sprite 1, opaque) is used"
         TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     MOVE 12.5 TO WS-X
     MOVE 2.7397 TO WS-Y
     MOVE 12.5 TO WS-Z
     CALL "TEST-MESH-VERTEX" USING WR-OP-ADDR(WS-ROW, 1) WR-OP-COUNT(WS-ROW, 1) WS-X WS-Y WS-Z
         WS-FOUND WS-B WS-U WS-V WS-SKY WS-R WS-G WS-BLUE
     COMPUTE WS-EXPECT-U = AT-X(1) / AT-W
     IF WS-FOUND = 1 AND FUNCTION ABS(WS-U - WS-EXPECT-U) < 0.0001
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> The vertex count of the translucent mesh minus the other cases' quads: the isolated source's 5 quads are all of its own cell; the
*> whole mesh holds that and the other cases, so count the quads whose centre is within the cell's column (x 12 to 13, z 12 to 13).
 FIND-ISOLATED-COUNT.
     MOVE 0 TO WS-N
     MOVE 12.5 TO WS-X
     MOVE 2.7397 TO WS-Y
     MOVE 12.5 TO WS-Z
     PERFORM FIND-WATER
     ADD WS-FOUND TO WS-N
     MOVE 2.3704 TO WS-Y
     MOVE 12.001 TO WS-Z
     PERFORM FIND-WATER
     ADD WS-FOUND TO WS-N
     MOVE 12.999 TO WS-Z
     PERFORM FIND-WATER
     ADD WS-FOUND TO WS-N
     MOVE 12.5 TO WS-Z
     MOVE 12.001 TO WS-X
     PERFORM FIND-WATER
     ADD WS-FOUND TO WS-N
     MOVE 12.999 TO WS-X
     PERFORM FIND-WATER
     ADD WS-FOUND TO WS-N
     COMPUTE TL-OBSERVED-N = WS-N * 6
     EXIT PARAGRAPH.

*> Looks the quad up in the translucent mesh; WS-TEXT is "found" or "none".
 FIND-WATER.
     CALL "TEST-MESH-VERTEX" USING WR-TR-ADDR(WS-ROW, 1) WR-TR-COUNT(WS-ROW, 1) WS-X WS-Y WS-Z
         WS-FOUND WS-B WS-U WS-V WS-SKY WS-R WS-G WS-BLUE
     MOVE SPACES TO WS-TEXT
     IF WS-FOUND = 1
         MOVE "found" TO WS-TEXT
     ELSE
         MOVE "none" TO WS-TEXT
     END-IF
     EXIT PARAGRAPH.

 RGB-TEXT.
     COMPUTE WS-E1 ROUNDED = WS-R * 255
     COMPUTE WS-E2 ROUNDED = WS-G * 255
     COMPUTE WS-E3 ROUNDED = WS-BLUE * 255
     MOVE SPACES TO WS-TEXT
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3)
         DELIMITED BY SIZE INTO WS-TEXT
     EXIT PARAGRAPH.
 END PROGRAM TEST-MESHER-FLUID.
 COPY CLTEST.
