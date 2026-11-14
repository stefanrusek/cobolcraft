*> Implementation test of the block helpers of the mineshaft pieces (docs/protocol/36-structures-5 sections 2.7 to 2.10; 36-1 6.5): fillPillarDownOrChainUp (a pillar down to a floor, a fence and a
*> chain up to a ceiling, the limits, a falling ceiling, lava), cobwebs (two full neighbours, the chance, the edge of the write box), the chest minecart rail, the supports without a ceiling and
*> with a single plank, the double support, invalid locations (a liquid on each of the six faces, a blocking biome), placeBlock's refusal to replace the piece's own wood, and the skip-air forms
*> of the box helpers. The world is a chunk of stone up to y 70.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-5-3.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 COPY CELLS.
 COPY FEATLEVEL.
 COPY STRUCTPIECE.
 COPY STRUCTBLK.
 COPY STRUCTDATA.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/struct-ms".
 01 WS-STATUS              BINARY-LONG.
 01 WS-PTR                 USAGE POINTER.
 01 WS-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==A-==.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-LAVA                BINARY-LONG.
 01 WS-SAND                BINARY-LONG.
 01 WS-SEAGRASS            BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(160).
 01 WS-CX                  BINARY-LONG VALUE 0.
 01 WS-CZ                  BINARY-LONG VALUE 0.
 01 WS-MIN                 BINARY-LONG VALUE -64.
 01 WS-HEIGHT              BINARY-LONG VALUE 384.
 01 WS-SEA                 BINARY-LONG VALUE 63.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-PT                  BINARY-LONG.
 01 WS-PO                  BINARY-LONG.
 01 WS-MST                 BINARY-LONG VALUE 0.
 01 WS-DEP                 BINARY-LONG VALUE 0.
 01 WS-INV                 BINARY-LONG.
 01 WS-CHANCE              FLOAT-LONG.
 01 WS-ONE                 FLOAT-LONG VALUE 1.0.
 01 WS-ZERO                FLOAT-LONG VALUE 0.0.
 01 WS-X0                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-SKIP                BINARY-LONG.
 01 WS-INT                 BINARY-LONG.
 01 WS-AIR                 BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-LIQ-X               BINARY-LONG.
 01 WS-LIQ-Y               BINARY-LONG.
 01 WS-LIQ-Z               BINARY-LONG.
 01 WS-HITS                BINARY-LONG.
 01 WS-XS                  BINARY-DOUBLE.
 01 WS-SD                  BINARY-DOUBLE UNSIGNED.
 COPY XORO REPLACING ==XR-STATE== BY ==WS-XR== LEADING ==XR-== BY ==WX-==.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE "content/tests/fixtures/std" TO CS-GENERATED-DIR
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "STRUCT-LOAD" USING WS-DIR WS-STATUS
     ALLOCATE 304640 CHARACTERS INITIALIZED RETURNING WS-PTR
     MOVE SPACES TO WS-PAIRS
     MOVE "minecraft:stone" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STONE
     MOVE "minecraft:lava" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-LAVA
     MOVE "minecraft:sand" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-SAND
     MOVE "minecraft:seagrass" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-SEAGRASS
     PERFORM STONE-WORLD
     MOVE "acceptance US12 36-5§2.7 Mineshaft helpers: the flags table marks sand as falling (1), seagrass replaceable (2) and a concrete powder falling" TO TL-CASE
     CALL "FL-BLOCK-OF" USING WS-SAND WS-I
     CALL "FL-BLOCK-OF" USING WS-SEAGRASS WS-J
     COMPUTE TL-OBSERVED-N = SB-FLAGS(WS-I) * 10 + SB-FLAGS(WS-J)
     MOVE 12 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:red_concrete_powder" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-S
     CALL "FL-BLOCK-OF" USING WS-S WS-I
     MOVE "acceptance US12 36-5§2.7 Mineshaft helpers: red concrete powder falls too" TO TL-CASE
     MOVE SB-FLAGS(WS-I) TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   fillPillarDownOrChainUp: the document's examples. A plank at y 40; air down to 36, stone at 35: logs 36 to 39
     MOVE 2 TO WS-PT
     MOVE -1 TO WS-PO
     MOVE 0 TO A-X0
     MOVE 0 TO A-Y0
     MOVE 0 TO A-Z0
     MOVE 15 TO A-X1
     MOVE 60 TO A-Y1
     MOVE 15 TO A-Z1
     PERFORM ADD-PIECE
     MOVE 5 TO WS-X
     MOVE 5 TO WS-Z
     PERFORM VARYING WS-Y FROM 36 BY 1 UNTIL WS-Y > 39
         MOVE 0 TO WS-S
         PERFORM SET-CELL
     END-PERFORM
     MOVE 40 TO WS-Y
     MOVE SB-PLANKS-S(1) TO WS-S
     PERFORM SET-CELL
     CALL "MSP-PILLAR" USING WS-ROW SB-LOG-S(1) WS-X WS-Y WS-Z
     MOVE 36 TO WS-Y
     MOVE SB-LOG-S(1) TO WS-WANT
     MOVE "acceptance US12 36-5§2.7 Mineshaft pillar: the example of the document: a plank at y 40 with air down to y 36 and stone below gets wood from y 36" TO TL-CASE
     PERFORM CHECK-CELL
     MOVE 39 TO WS-Y
     MOVE "acceptance US12 36-5§2.7 Mineshaft pillar: up to y 39, the cell below the plank" TO TL-CASE
     PERFORM CHECK-CELL
     MOVE 35 TO WS-Y
     MOVE WS-STONE TO WS-WANT
     MOVE "acceptance US12 36-5§2.7 Mineshaft pillar: the stone floor at y 35 stays" TO TL-CASE
     PERFORM CHECK-CELL
*>   seagrass in the column is free, lava is not: a lava cell stops the descent and the column looks up
     MOVE 7 TO WS-X
     MOVE 7 TO WS-Z
     PERFORM VARYING WS-Y FROM 37 BY 1 UNTIL WS-Y > 39
         MOVE WS-SEAGRASS TO WS-S
         PERFORM SET-CELL
     END-PERFORM
     MOVE 36 TO WS-Y
     MOVE WS-LAVA TO WS-S
     PERFORM SET-CELL
     MOVE 40 TO WS-Y
     MOVE SB-PLANKS-S(1) TO WS-S
     PERFORM SET-CELL
     PERFORM VARYING WS-Y FROM 41 BY 1 UNTIL WS-Y > 45
         MOVE 0 TO WS-S
         PERFORM SET-CELL
     END-PERFORM
     MOVE 40 TO WS-Y
     CALL "MSP-PILLAR" USING WS-ROW SB-LOG-S(1) WS-X WS-Y WS-Z
     MOVE 41 TO WS-Y
     MOVE SB-FENCE-P(1) TO WS-WANT
     MOVE "acceptance US12 36-5§2.7 Mineshaft pillar: lava stops the downward look; looking up, a stone ceiling at y 46 gets a fence at y 41 and chain below it" TO TL-CASE
     PERFORM CHECK-CELL
     MOVE 42 TO WS-Y
     MOVE SB-S-CHAIN TO WS-WANT
     MOVE "acceptance US12 36-5§2.7 Mineshaft pillar: chain from y 42" TO TL-CASE
     PERFORM CHECK-CELL
     MOVE 45 TO WS-Y
     MOVE "acceptance US12 36-5§2.7 Mineshaft pillar: to y 45, just below the ceiling" TO TL-CASE
     PERFORM CHECK-CELL
     MOVE 38 TO WS-Y
     MOVE WS-SEAGRASS TO WS-WANT
     MOVE "acceptance US12 36-5§2.7 Mineshaft pillar: nothing is written below" TO TL-CASE
     PERFORM CHECK-CELL
*>   a sand ceiling does not hold a chain
     MOVE 9 TO WS-X
     MOVE 9 TO WS-Z
     MOVE 36 TO WS-Y
     MOVE WS-LAVA TO WS-S
     PERFORM SET-CELL
     MOVE 40 TO WS-Y
     MOVE SB-PLANKS-S(1) TO WS-S
     PERFORM SET-CELL
     PERFORM VARYING WS-Y FROM 37 BY 1 UNTIL WS-Y > 39
         MOVE WS-LAVA TO WS-S
         PERFORM SET-CELL
     END-PERFORM
     PERFORM VARYING WS-Y FROM 41 BY 1 UNTIL WS-Y > 45
         MOVE 0 TO WS-S
         PERFORM SET-CELL
     END-PERFORM
     MOVE 46 TO WS-Y
     MOVE WS-SAND TO WS-S
     PERFORM SET-CELL
     MOVE 40 TO WS-Y
     CALL "MSP-PILLAR" USING WS-ROW SB-LOG-S(1) WS-X WS-Y WS-Z
     MOVE 41 TO WS-Y
     MOVE 0 TO WS-WANT
     MOVE "acceptance US12 36-5§2.7 Mineshaft pillar: a sand ceiling is a falling block: no fence, no chain" TO TL-CASE
     PERFORM CHECK-CELL
*>   a block directly above the post: nothing is hung
     MOVE 11 TO WS-X
     MOVE 11 TO WS-Z
     MOVE 40 TO WS-Y
     MOVE SB-PLANKS-S(1) TO WS-S
     PERFORM SET-CELL
     MOVE 39 TO WS-Y
     MOVE WS-LAVA TO WS-S
     PERFORM SET-CELL
     MOVE 40 TO WS-Y
     CALL "MSP-PILLAR" USING WS-ROW SB-LOG-S(1) WS-X WS-Y WS-Z
     MOVE 41 TO WS-Y
     MOVE WS-STONE TO WS-WANT
     MOVE "acceptance US12 36-5§2.7 Mineshaft pillar: stone directly above the post (one cell up) is not overwritten by a fence" TO TL-CASE
     PERFORM CHECK-CELL
*>   limits: down at min y + 2, up at the top
     MOVE 13 TO WS-X
     MOVE 13 TO WS-Z
     MOVE -60 TO WS-Y
     MOVE SB-PLANKS-S(1) TO WS-S
     PERFORM SET-CELL
     PERFORM VARYING WS-Y FROM -63 BY 1 UNTIL WS-Y > -61
         MOVE 0 TO WS-S
         PERFORM SET-CELL
     END-PERFORM
     MOVE -60 TO WS-Y
     CALL "MSP-PILLAR" USING WS-ROW SB-LOG-S(1) WS-X WS-Y WS-Z
     MOVE -61 TO WS-Y
     MOVE 0 TO WS-WANT
     MOVE "acceptance US12 36-5§2.7 Mineshaft pillar: the look down stops at min y + 2: nothing is built toward the bottom layers" TO TL-CASE
     PERFORM CHECK-CELL
     MOVE 3 TO WS-X
     MOVE 3 TO WS-Z
     MOVE 315 TO WS-Y
     MOVE SB-PLANKS-S(1) TO WS-S
     PERFORM SET-CELL
     MOVE 2 TO WS-DEP
     MOVE 380 TO A-Y1
     CALL "SPB-BOX-NEW" USING A-X0 A-Y0 A-Z0 A-X1 A-Y1 A-Z1 WS-BOX
     CALL "MSP-PILLAR" USING WS-ROW SB-LOG-S(1) WS-X WS-Y WS-Z
     MOVE 316 TO WS-Y
     MOVE 0 TO WS-WANT
     MOVE "acceptance US12 36-5§2.7 Mineshaft pillar: the look up stops before the top of the level: nothing at y 316 (air)" TO TL-CASE
     PERFORM CHECK-CELL
     MOVE 20 TO WS-X
     MOVE 40 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "MSP-PILLAR" USING WS-ROW SB-LOG-S(1) WS-X WS-Y WS-Z
     MOVE "acceptance US12 36-5§2.7 Mineshaft pillar: a post outside the write box does nothing (no overflow recorded)" TO TL-CASE
     MOVE FL-OV-COUNT TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   cobwebs (2.8): a cell inside rock has six full neighbours; chance 1 places, chance 0 draws and does not; a lone cell in a big cave has none; the box edge has an outside neighbour
     PERFORM STONE-WORLD
     MOVE 2 TO WS-PT
     MOVE -1 TO WS-PO
     MOVE 0 TO A-X0
     MOVE 0 TO A-Y0
     MOVE 0 TO A-Z0
     MOVE 15 TO A-X1
     MOVE 60 TO A-Y1
     MOVE 15 TO A-Z1
     PERFORM ADD-PIECE
     MOVE 5 TO WS-X
     MOVE 50 TO WS-Y
     MOVE 5 TO WS-Z
     MOVE 0 TO WS-S
     PERFORM SET-CELL
     CALL "MSP-COBWEB" USING WS-ROW WS-ZERO WS-X WS-Y WS-Z
     MOVE 0 TO WS-WANT
     MOVE "acceptance US12 36-5§2.8 Mineshaft cobweb: a draw not below the chance places nothing" TO TL-CASE
     PERFORM CHECK-CELL
     CALL "MSP-COBWEB" USING WS-ROW WS-ONE WS-X WS-Y WS-Z
     MOVE SB-S-COBWEB TO WS-WANT
     MOVE "acceptance US12 36-5§2.8 Mineshaft cobweb: with chance 1 and six full neighbours the cobweb is placed" TO TL-CASE
     PERFORM CHECK-CELL
     MOVE 0 TO WS-X
     MOVE 0 TO WS-S
     PERFORM SET-CELL
     CALL "MSP-COBWEB" USING WS-ROW WS-ONE WS-X WS-Y WS-Z
     MOVE SB-S-COBWEB TO WS-WANT
     MOVE "acceptance US12 36-5§2.8 Mineshaft cobweb: at the west edge of the chunk the outside neighbour does not count, five full ones remain" TO TL-CASE
     PERFORM CHECK-CELL
     PERFORM VARYING WS-X FROM 8 BY 1 UNTIL WS-X > 12
         PERFORM VARYING WS-Y FROM 48 BY 1 UNTIL WS-Y > 52
             PERFORM VARYING WS-Z FROM 8 BY 1 UNTIL WS-Z > 12
                 MOVE 0 TO WS-S
                 PERFORM SET-CELL
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE 10 TO WS-X
     MOVE 50 TO WS-Y
     MOVE 10 TO WS-Z
     CALL "MSP-COBWEB" USING WS-ROW WS-ONE WS-X WS-Y WS-Z
     MOVE 0 TO WS-WANT
     MOVE "acceptance US12 36-5§2.8 Mineshaft cobweb: a lone cell in a cave has no full neighbour: nothing" TO TL-CASE
     PERFORM CHECK-CELL
     MOVE 8 TO WS-X
     MOVE 8 TO WS-Z
     MOVE 75 TO WS-Y
     CALL "MSP-COBWEB" USING WS-ROW WS-ONE WS-X WS-Y WS-Z
     MOVE "acceptance US12 36-5§2.8 Mineshaft cobweb: a cell above the surface (not interior) draws nothing and places nothing" TO TL-CASE
     MOVE 0 TO WS-WANT
     PERFORM CHECK-CELL

*>   the chest minecart rail (2.10): outside the box, on a solid cell, over air: refused; on a free cell with ground: a rail
     MOVE 5 TO WS-X
     MOVE 30 TO WS-Y
     MOVE 5 TO WS-Z
     MOVE 0 TO WS-S
     PERFORM SET-CELL
     MOVE SP-XR-LO TO WS-XS
     MOVE 20 TO WS-X
     CALL "MSP-CART" USING WS-ROW WS-X WS-Y WS-Z
     MOVE 5 TO WS-X
     MOVE 31 TO WS-Y
     CALL "MSP-CART" USING WS-ROW WS-X WS-Y WS-Z
     MOVE 30 TO WS-Y
     MOVE 29 TO WS-Y
     MOVE 0 TO WS-S
     PERFORM SET-CELL
     MOVE 30 TO WS-Y
     CALL "MSP-CART" USING WS-ROW WS-X WS-Y WS-Z
     MOVE "acceptance US12 36-5§2.10 Mineshaft chest minecart: the refusals (outside the box, a solid cell, air below) draw nothing: the stream is where it started" TO TL-CASE
     MOVE SP-XR-LO TO TL-OBSERVED-N
     MOVE WS-XS TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 29 TO WS-Y
     MOVE WS-STONE TO WS-S
     PERFORM SET-CELL
     MOVE 30 TO WS-Y
     CALL "MSP-CART" USING WS-ROW WS-X WS-Y WS-Z
     PERFORM CELL-STATE
     MOVE "acceptance US12 36-5§2.10 Mineshaft chest minecart: a free cell with ground gets a rail (north_south or east_west)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     IF WS-S = SB-S-RAIL(1) OR WS-S = SB-S-RAIL(2)
         MOVE 1 TO TL-EXPECTED-N
     END-IF
     MOVE 1 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-5§2.10 Mineshaft chest minecart: and draws (the shape, the loot seed): the stream moved" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     IF SP-XR-LO NOT = WS-XS
         MOVE 1 TO TL-EXPECTED-N
     END-IF
     MOVE 1 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO SP-ORIENT(WS-ROW)
     MOVE 0 TO WS-S
     MOVE 30 TO WS-Y
     PERFORM SET-CELL
     CALL "MSP-CART" USING WS-ROW WS-X WS-Y WS-Z
     MOVE -1 TO SP-ORIENT(WS-ROW)

*>   the supports: without a ceiling nothing, with one a post pair; many seeds reach both the single plank and the beam
     PERFORM STONE-WORLD
     PERFORM ADD-PIECE
     MOVE 3 TO SP-ORIENT(WS-ROW)
     MOVE 4 TO SP-X0(WS-ROW)
     MOVE 50 TO SP-Y0(WS-ROW)
     MOVE 4 TO SP-Z0(WS-ROW)
     MOVE 6 TO SP-X1(WS-ROW)
     MOVE 52 TO SP-Y1(WS-ROW)
     MOVE 6 TO SP-Z1(WS-ROW)
     MOVE 4 TO WS-X
     MOVE 53 TO WS-Y
     MOVE 5 TO WS-Z
     MOVE 0 TO WS-S
     PERFORM SET-CELL
     MOVE 0 TO WS-Z
     CALL "MSP-SUPPORT" USING WS-ROW WS-Z
     MOVE 4 TO WS-X
     MOVE 52 TO WS-Y
     MOVE 4 TO WS-Z
     MOVE WS-STONE TO WS-WANT
     MOVE "acceptance US12 36-5§2.7 Mineshaft support: air in the row above the beam means no ceiling: nothing is placed" TO TL-CASE
     PERFORM CHECK-CELL
     MOVE 0 TO WS-HITS
     MOVE 4 TO WS-X
     MOVE 53 TO WS-Y
     MOVE 5 TO WS-Z
     MOVE WS-STONE TO WS-S
     PERFORM SET-CELL
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 24
         MOVE WS-J TO WS-SD
         CALL "WGR-SET-SEED" USING WS-XR WS-SD
         MOVE WX-LO TO SP-XR-LO
         MOVE WX-HI TO SP-XR-HI
         MOVE 4 TO WS-X
         MOVE 52 TO WS-Y
         MOVE 5 TO WS-Z
         MOVE WS-STONE TO WS-S
         PERFORM SET-CELL
         MOVE 0 TO WS-Z
         CALL "MSP-SUPPORT" USING WS-ROW WS-Z
         MOVE 5 TO WS-Z
         PERFORM CELL-STATE
         IF WS-S = WS-STONE
             ADD 1 TO WS-HITS
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-5§2.7 Mineshaft support: over 24 seeds some give two single planks (the middle cell stays stone) and some a beam (nextInt(4) is 0 about a quarter of the time)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     IF WS-HITS > 0 AND WS-HITS < 24
         MOVE 1 TO TL-EXPECTED-N
     END-IF
     MOVE 1 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the double support (2.7): planks at x and x + 2 each get a pillar
     PERFORM STONE-WORLD
     PERFORM ADD-PIECE
     MOVE 5 TO WS-Z
     MOVE 5 TO WS-X
     PERFORM VARYING WS-Y FROM 36 BY 1 UNTIL WS-Y > 40
         MOVE 0 TO WS-S
         PERFORM SET-CELL
         ADD 2 TO WS-X
         PERFORM SET-CELL
         SUBTRACT 2 FROM WS-X
     END-PERFORM
     MOVE 40 TO WS-Y
     MOVE SB-PLANKS-S(1) TO WS-S
     PERFORM SET-CELL
     ADD 2 TO WS-X
     PERFORM SET-CELL
     SUBTRACT 2 FROM WS-X
     CALL "MSP-DOUBLE" USING WS-ROW WS-X WS-Y WS-Z
     MOVE 38 TO WS-Y
     MOVE SB-LOG-S(1) TO WS-WANT
     MOVE "acceptance US12 36-5§2.7 Mineshaft double support: the post at x gets a pillar" TO TL-CASE
     PERFORM CHECK-CELL
     ADD 2 TO WS-X
     MOVE "acceptance US12 36-5§2.7 Mineshaft double support: and the post at x + 2" TO TL-CASE
     PERFORM CHECK-CELL
     SUBTRACT 2 FROM WS-X

*>   placeBlock refuses to replace the piece's own wood (2.9) but replaces another type's
     MOVE 6 TO WS-X
     MOVE 6 TO WS-Z
     MOVE 20 TO WS-Y
     MOVE SB-PLANKS-S(1) TO WS-S
     PERFORM SET-CELL
     CALL "MSP-PLACE" USING WS-ROW WS-X WS-Y WS-Z WS-STONE
     MOVE SB-PLANKS-S(1) TO WS-WANT
     MOVE "acceptance US12 36-5§2.9 Mineshaft: an oak piece does not overwrite oak planks" TO TL-CASE
     PERFORM CHECK-CELL
     MOVE 1 TO SP-MST(WS-ROW)
     CALL "MSP-PLACE" USING WS-ROW WS-X WS-Y WS-Z WS-STONE
     MOVE WS-STONE TO WS-WANT
     MOVE "acceptance US12 36-5§2.9 Mineshaft: a mesa piece (dark oak) overwrites oak planks" TO TL-CASE
     PERFORM CHECK-CELL
     MOVE 0 TO SP-MST(WS-ROW)

*>   the skip-air forms: generateBox, generateMaybeBox and the sphere leave cells that are air
     MOVE 8 TO WS-X
     MOVE 8 TO WS-Z
     MOVE 25 TO WS-Y
     MOVE 0 TO WS-S
     PERFORM SET-CELL
     MOVE 1 TO WS-SKIP
     MOVE 8 TO WS-X0
     MOVE 25 TO WS-Y0
     MOVE 8 TO WS-Z0
     MOVE 9 TO WS-X1
     MOVE 25 TO WS-Y1
     MOVE 8 TO WS-Z1
     CALL "MSP-BOX" USING WS-ROW WS-X0 WS-Y0 WS-Z0 WS-X1 WS-Y1 WS-Z1 SB-PLANKS-S(1) SB-S-CAVE-AIR WS-SKIP
     MOVE 0 TO WS-WANT
     MOVE "acceptance US12 36-5§6.5 Mineshaft: generateBox with skipAir leaves an air cell" TO TL-CASE
     PERFORM CHECK-CELL
     MOVE 9 TO WS-X
     MOVE SB-PLANKS-S(1) TO WS-WANT
     MOVE "acceptance US12 36-5§6.5 Mineshaft: and fills the rock cell next to it" TO TL-CASE
     PERFORM CHECK-CELL
     MOVE 1 TO WS-SKIP
     MOVE 8 TO WS-X
     MOVE 0 TO WS-I
     CALL "MSP-MAYBE-BOX" USING WS-ROW WS-ONE WS-X0 WS-Y0 WS-Z0 WS-X1 WS-Y1 WS-Z1 SB-S-COBWEB BY CONTENT SB-S-COBWEB WS-SKIP BY REFERENCE WS-SKIP
     MOVE 0 TO WS-WANT
     MOVE "acceptance US12 36-5§6.5 Mineshaft: generateMaybeBox with skipAir leaves the air cell too (the cell above the surface is not interior, none placed in air)" TO TL-CASE
     PERFORM CHECK-CELL
     MOVE 8 TO WS-X0
     MOVE 25 TO WS-Y0
     MOVE 8 TO WS-Z0
     MOVE 10 TO WS-X1
     MOVE 28 TO WS-Y1
     MOVE 10 TO WS-Z1
     CALL "MSP-SPHERE" USING WS-ROW WS-X0 WS-Y0 WS-Z0 WS-X1 WS-Y1 WS-Z1 SB-S-CAVE-AIR WS-SKIP
     MOVE 8 TO WS-X
     MOVE 25 TO WS-Y
     MOVE 8 TO WS-Z
     MOVE 0 TO WS-WANT
     MOVE "acceptance US12 36-5§6.5 Mineshaft: the sphere with skipAir leaves an air cell (it would write cave air, a different state)" TO TL-CASE
     PERFORM CHECK-CELL

*>   invalid locations (2.9): lava on each of the six faces of the box grown by one, then a blocking biome
     MOVE 0 TO WS-HITS
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 7
         PERFORM STONE-WORLD
         MOVE 2 TO WS-PT
         MOVE -1 TO WS-PO
         MOVE 5 TO A-X0
         MOVE 50 TO A-Y0
         MOVE 5 TO A-Z0
         MOVE 9 TO A-X1
         MOVE 52 TO A-Y1
         MOVE 9 TO A-Z1
         PERFORM ADD-PIECE
         MOVE 7 TO WS-X
         MOVE 51 TO WS-Y
         MOVE 7 TO WS-Z
         EVALUATE WS-J
             WHEN 1
                 MOVE 49 TO WS-Y
             WHEN 2
                 MOVE 53 TO WS-Y
             WHEN 3
                 MOVE 4 TO WS-X
             WHEN 4
                 MOVE 10 TO WS-X
             WHEN 5
                 MOVE 4 TO WS-Z
             WHEN 6
                 MOVE 10 TO WS-Z
         END-EVALUATE
         IF WS-J < 7
             MOVE WS-LAVA TO WS-S
             PERFORM SET-CELL
         END-IF
         CALL "MSP-INVALID" USING WS-ROW WS-INV
         ADD WS-INV TO WS-HITS
         IF WS-J = 7
             MOVE "acceptance US12 36-5§2.9 Mineshaft: a piece in rock with no liquid around is valid (the 7th case)" TO TL-CASE
             MOVE WS-INV TO TL-OBSERVED-N
             MOVE 0 TO TL-EXPECTED-N
             CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-5§2.9 Mineshaft: lava on any of the six faces (below, above, west, east, north, south) makes the location invalid (6 of 6)" TO TL-CASE
     MOVE WS-HITS TO TL-OBSERVED-N
     MOVE 6 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   a blocking biome: every biome cell of the chunk is deep_dark, then MS-POST places nothing
     PERFORM STONE-WORLD
     MOVE 0 TO WS-ID
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CBI-COUNT
         IF CBI-KEY(WS-I) = "minecraft:desert"
             COMPUTE WS-ID = WS-I - 1
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 1536
         MOVE WS-ID TO CE-BIOME(WS-I)
     END-PERFORM
     MOVE 2 TO WS-PT
     MOVE -1 TO WS-PO
     MOVE 5 TO A-X0
     MOVE 50 TO A-Y0
     MOVE 5 TO A-Z0
     MOVE 9 TO A-X1
     MOVE 52 TO A-Y1
     MOVE 9 TO A-Z1
     PERFORM ADD-PIECE
     MOVE 7 TO WS-X
     MOVE 51 TO WS-Y
     MOVE 7 TO WS-Z
     CALL "MS-POST" USING WS-ROW
     MOVE WS-STONE TO WS-WANT
     MOVE "acceptance US12 36-5§2.9 Mineshaft: in a blocking biome (the fixture's tag holds deep_dark and desert; the world has desert) the room is not placed" TO TL-CASE
     PERFORM CHECK-CELL

*>   a room with an entrance: the entrance box is opened to the head
     PERFORM STONE-WORLD
     PERFORM ADD-PIECE
     MOVE 1 TO SP-ENT-FIRST(WS-ROW)
     MOVE 1 TO SP-ENT-N(WS-ROW)
     MOVE 1 TO SP-ENT-COUNT
     MOVE 3 TO SE-X0(1)
     MOVE 56 TO SE-Y0(1)
     MOVE 3 TO SE-Z0(1)
     MOVE 5 TO SE-X1(1)
     MOVE 60 TO SE-Y1(1)
     MOVE 3 TO SE-Z1(1)
     MOVE 3 TO A-X0
     MOVE 50 TO A-Y0
     MOVE 3 TO A-Z0
     MOVE 9 TO A-X1
     MOVE 62 TO A-Y1
     MOVE 9 TO A-Z1
     MOVE A-X0 TO SP-X0(WS-ROW)
     MOVE A-Y0 TO SP-Y0(WS-ROW)
     MOVE A-Z0 TO SP-Z0(WS-ROW)
     MOVE A-X1 TO SP-X1(WS-ROW)
     MOVE A-Y1 TO SP-Y1(WS-ROW)
     MOVE A-Z1 TO SP-Z1(WS-ROW)
     MOVE 0 TO CE-BIOME(1)
     CALL "MS-POST" USING WS-ROW
     MOVE 4 TO WS-X
     MOVE 59 TO WS-Y
     MOVE 3 TO WS-Z
     MOVE SB-S-CAVE-AIR TO WS-WANT
     MOVE "acceptance US12 36-5§2.5 Mineshaft room: an entrance box (y 56 to 60) is opened from maxY - 2 up: (4,59,3) is air" TO TL-CASE
     PERFORM CHECK-CELL
     MOVE 56 TO WS-Y
     MOVE WS-STONE TO WS-WANT
     MOVE "acceptance US12 36-5§2.5 Mineshaft room: and below that the rock stays: (4,56,3)" TO TL-CASE
     PERFORM CHECK-CELL

*>   many corridors: the chest minecart rails (1 in 100 per side and section) happen; a west corridor turns its rails east-west
     MOVE 0 TO WS-HITS
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 60
         PERFORM STONE-WORLD
         MOVE 0 TO WS-PT
         MOVE 1 TO WS-PO
         MOVE 0 TO A-X0
         MOVE 50 TO A-Y0
         MOVE 4 TO A-Z0
         MOVE 14 TO A-X1
         MOVE 52 TO A-Y1
         MOVE 6 TO A-Z1
         PERFORM ADD-PIECE
         MOVE 3 TO SP-F4(WS-ROW)
         MOVE 1 TO SP-F1(WS-ROW)
         MOVE WS-J TO WS-SD
         CALL "WGR-SET-SEED" USING WS-XR WS-SD
         MOVE WX-LO TO SP-XR-LO
         MOVE WX-HI TO SP-XR-HI
         CALL "MS-POST" USING WS-ROW
         MOVE 5 TO WS-Z
         MOVE 50 TO WS-Y
         PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 14
             PERFORM CELL-STATE
             IF WS-S = SB-S-RAIL(2)
                 ADD 1 TO WS-HITS
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "acceptance US12 36-5§6.4 Mineshaft corridor west with rails: the rails run east-west (some of 60 corridors x 15 cells)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     IF WS-HITS > 100
         MOVE 1 TO TL-EXPECTED-N
     END-IF
     MOVE 1 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the chain over seagrass: seagrass above the post is free, the stone ceiling at y 45 holds the chain
     PERFORM STONE-WORLD
     MOVE 2 TO WS-PT
     MOVE -1 TO WS-PO
     MOVE 0 TO A-X0
     MOVE 0 TO A-Y0
     MOVE 0 TO A-Z0
     MOVE 15 TO A-X1
     MOVE 60 TO A-Y1
     MOVE 15 TO A-Z1
     PERFORM ADD-PIECE
     MOVE 6 TO WS-X
     MOVE 6 TO WS-Z
     MOVE 39 TO WS-Y
     MOVE WS-LAVA TO WS-S
     PERFORM SET-CELL
     MOVE 40 TO WS-Y
     MOVE SB-PLANKS-S(1) TO WS-S
     PERFORM SET-CELL
     MOVE 41 TO WS-Y
     MOVE WS-SEAGRASS TO WS-S
     PERFORM SET-CELL
     PERFORM VARYING WS-Y FROM 42 BY 1 UNTIL WS-Y > 44
         MOVE 0 TO WS-S
         PERFORM SET-CELL
     END-PERFORM
     MOVE 40 TO WS-Y
     CALL "MSP-PILLAR" USING WS-ROW SB-LOG-S(1) WS-X WS-Y WS-Z
     MOVE 44 TO WS-Y
     MOVE SB-S-CHAIN TO WS-WANT
     MOVE "acceptance US12 36-5§2.7 Mineshaft pillar: seagrass above the post is replaceable by structures, so the look up goes on and hangs the chain to y 44" TO TL-CASE
     PERFORM CHECK-CELL

*>   generateMaybeBox with a chance below 1: some cells are skipped, the inside takes the fill state and the edge the edge state
     PERFORM STONE-WORLD
     PERFORM ADD-PIECE
     MOVE 0.5 TO WS-CHANCE
     MOVE 2 TO WS-X0
     MOVE 40 TO WS-Y0
     MOVE 2 TO WS-Z0
     MOVE 9 TO WS-X1
     MOVE 47 TO WS-Y1
     MOVE 9 TO WS-Z1
     MOVE 0 TO WS-SKIP
     CALL "MSP-MAYBE-BOX" USING WS-ROW WS-CHANCE WS-X0 WS-Y0 WS-Z0 WS-X1 WS-Y1 WS-Z1 SB-S-COBWEB SB-S-CAVE-AIR WS-SKIP BY CONTENT WS-SKIP
     MOVE 0 TO WS-HITS
     MOVE 0 TO WS-J
     PERFORM VARYING WS-X FROM 3 BY 1 UNTIL WS-X > 8
         PERFORM VARYING WS-Y FROM 41 BY 1 UNTIL WS-Y > 46
             PERFORM VARYING WS-Z FROM 3 BY 1 UNTIL WS-Z > 8
                 PERFORM CELL-STATE
                 IF WS-S = SB-S-CAVE-AIR
                     ADD 1 TO WS-HITS
                 END-IF
                 IF WS-S = WS-STONE
                     ADD 1 TO WS-J
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE "acceptance US12 36-5§6.5 Mineshaft generateMaybeBox 0.5: of the 216 inner cells some are filled and some skipped" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     IF WS-HITS > 50 AND WS-J > 50
         MOVE 1 TO TL-EXPECTED-N
     END-IF
     MOVE 1 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   many short corridors: the second chest minecart rail (1 in 100, on the cell after the section centre) happens
     MOVE 0 TO WS-HITS
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 500
         PERFORM STONE-WORLD
         MOVE 0 TO WS-PT
         MOVE 2 TO WS-PO
         MOVE 4 TO A-X0
         MOVE 50 TO A-Y0
         MOVE 0 TO A-Z0
         MOVE 6 TO A-X1
         MOVE 52 TO A-Y1
         MOVE 4 TO A-Z1
         PERFORM ADD-PIECE
         MOVE 1 TO SP-F4(WS-ROW)
         MOVE WS-J TO WS-SD
         CALL "WGR-SET-SEED" USING WS-XR WS-SD
         MOVE WX-LO TO SP-XR-LO
         MOVE WX-HI TO SP-XR-HI
         CALL "MS-POST" USING WS-ROW
         MOVE 4 TO WS-X
         MOVE 50 TO WS-Y
         MOVE 1 TO WS-Z
         PERFORM CELL-STATE
         IF WS-S = SB-S-RAIL(1) OR WS-S = SB-S-RAIL(2)
             ADD 1 TO WS-HITS
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-5§2.10 Mineshaft: over 500 one-section corridors the rail of the second chest minecart (local (0,0,3), world (4,50,1)) appears at least once" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     IF WS-HITS > 0
         MOVE 1 TO TL-EXPECTED-N
     END-IF
     MOVE 1 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   generateMaybeBox with requireInterior: cells above the surface are not interior and are skipped
     PERFORM STONE-WORLD
     PERFORM ADD-PIECE
     MOVE 3 TO WS-X0
     MOVE 75 TO WS-Y0
     MOVE 3 TO WS-Z0
     MOVE 4 TO WS-X1
     MOVE 75 TO WS-Y1
     MOVE 4 TO WS-Z1
     MOVE 0 TO WS-SKIP
     MOVE 1 TO WS-INT
     CALL "MSP-MAYBE-BOX" USING WS-ROW WS-ONE WS-X0 WS-Y0 WS-Z0 WS-X1 WS-Y1 WS-Z1 SB-S-COBWEB BY CONTENT SB-S-COBWEB WS-SKIP BY REFERENCE WS-INT
     MOVE 3 TO WS-X
     MOVE 75 TO WS-Y
     MOVE 3 TO WS-Z
     MOVE 0 TO WS-WANT
     MOVE "acceptance US12 36-5§6.5 Mineshaft generateMaybeBox with requireInterior: a cell above the surface is skipped" TO TL-CASE
     PERFORM CHECK-CELL
     STOP RUN.

 STONE-WORLD.
     CALL "SPB-RESET"
     SET ADDRESS OF CE-CHUNK TO WS-PTR
     MOVE LOW-VALUES TO CE-CHUNK
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 135 * 256
         MOVE WS-STONE TO CE-STATE(WS-I)
     END-PERFORM
     CALL "FL-OPEN" USING WS-PTR WS-CX WS-CZ WS-MIN WS-HEIGHT WS-SEA
     CALL "MSP-OPEN"
     MOVE 5 TO SP-XR-LO
     MOVE 7 TO SP-XR-HI.
 ADD-PIECE.
     CALL "SPB-ADD" USING WS-PT WS-PO WS-DEP WS-MST WS-BOX WS-ROW.
 SET-CELL.
     COMPUTE WS-I = (WS-Y + 64) * 256 + WS-Z * 16 + WS-X + 1
     MOVE WS-S TO CE-STATE(WS-I).
 CELL-STATE.
     COMPUTE WS-I = (WS-Y + 64) * 256 + WS-Z * 16 + WS-X + 1
     MOVE CE-STATE(WS-I) TO WS-S.
 CHECK-CELL.
     PERFORM CELL-STATE
     MOVE WS-S TO TL-OBSERVED-N
     MOVE WS-WANT TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 END PROGRAM TEST-STRUCT-36-5-3.
 COPY CORETEST.
