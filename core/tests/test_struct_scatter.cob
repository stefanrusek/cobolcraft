*> Acceptance test of the scattered feature pieces (docs/protocol/36-structures-4-scattered-and-small.md sections 2.3, 4 and 5: swamp hut and jungle temple; core/src/struct-scatter.cob and
*> struct-scatter-gen.cob). A piece is placed into a chunk window (a 16 x 384 x 16 buffer, air above y 61 and stone below) at the box (0, 64, 0): the hut and the temple in the four orientations (the mirror
*> and rotation of 2.3), the number of blocks written (the final count of an independent simulation of the document's tables, core/tests: 141 for the hut, 1222 for the temple), spot blocks of the
*> document, the containers of the temple (two dispensers with the piece's rotation, a main and a hidden chest: loot tables and flags, never twice), the moss stone selector, the clipping to the
*> write box (a piece across two chunks adds up to the whole), fillColumnDown, generateBox with skipAir, and reorient of a chest (36-1 6.5) in six layouts.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-SCATTER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 COPY CELLS.
 COPY FEATLEVEL.
 COPY STRUCTPIECE.
 COPY STRUCTDESERT.
 COPY STRUCTBLK.
 COPY GENBE.
 COPY GENENT.
 COPY XORO REPLACING ==XR-STATE== BY ==WS-XR== LEADING ==XR-== BY ==WX-==.
 01 WS-PTR                 USAGE POINTER.
 01 WS-I                   BINARY-LONG.
 01 WS-WCX                 BINARY-LONG.
 01 WS-WCZ                 BINARY-LONG.
 01 WS-MIN-Y               BINARY-LONG VALUE -64.
 01 WS-HEIGHT              BINARY-LONG VALUE 384.
 01 WS-SEA                 BINARY-LONG VALUE 63.
 01 WS-STONE               BINARY-LONG.
 01 WS-FSEED               BINARY-DOUBLE UNSIGNED VALUE 777.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(600).
 01 WS-WANT                BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SPEC                PIC X(60).
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Y64                 BINARY-LONG VALUE 64.
 01 WS-Z0                  BINARY-LONG.
 01 WS-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==B-==.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 01 WS-LY2                 BINARY-LONG.
 01 WS-FILL2               BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LY                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-WX                  BINARY-LONG.
 01 WS-WY                  BINARY-LONG.
 01 WS-WZ                  BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-COUNT2              BINARY-LONG.
 01 WS-COBBLE              BINARY-LONG.
 01 WS-MOSSY               BINARY-LONG.
 01 WS-COBBLES             BINARY-LONG.
 01 WS-OTHERS              BINARY-LONG.
 01 WS-LABEL               PIC X(60).
 01 WS-FACING              PIC X(5).
 01 WS-FACINGS.
    05 FILLER              PIC X(5) VALUE "south".
    05 FILLER              PIC X(5) VALUE "west ".
    05 FILLER              PIC X(5) VALUE "north".
    05 FILLER              PIC X(5) VALUE "east ".
 01 WS-FACING-TABLE REDEFINES WS-FACINGS.
    05 WS-FACING-OF        PIC X(5) OCCURS 4 TIMES.
 01 WS-SHAPES.
    05 FILLER              PIC X(11) VALUE "outer_left ".
    05 FILLER              PIC X(11) VALUE "outer_left ".
    05 FILLER              PIC X(11) VALUE "outer_right".
    05 FILLER              PIC X(11) VALUE "outer_right".
 01 WS-SHAPE-TABLE REDEFINES WS-SHAPES.
    05 WS-SHAPE-OF         PIC X(11) OCCURS 4 TIMES.
 01 WS-LOOT                PIC X(48).
 01 WS-PLACED              BINARY-LONG.
 01 WS-WANT-KEY            PIC X(48).
 01 WS-CHEST-SPEC          PIC X(60) VALUE SPACES.
 01 WS-X1                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-FILL                BINARY-LONG.
 01 WS-SKIP                BINARY-LONG.
 01 WS-STONE-CELLS         BINARY-LONG.
 01 WS-AIR-CELLS           BINARY-LONG.
 01 WS-DI                  BINARY-LONG.
 01 WS-INBOX               BINARY-LONG.
 01 WS-LX2                 BINARY-LONG.
 01 WS-LZ2                 BINARY-LONG.
 01 WS-OPS.
    05 FILLER              PIC X(100) VALUE "K 2 6 3 4 6 4 oak_log oak_log".
 01 WS-OPCOUNT             BINARY-LONG VALUE 1.
 01 WS-EXP-Xs.
    05 FILLER              BINARY-LONG VALUE 6.
    05 FILLER              BINARY-LONG VALUE 8.
    05 FILLER              BINARY-LONG VALUE 8.
    05 FILLER              BINARY-LONG VALUE 7.
    05 FILLER              BINARY-LONG VALUE 7.
    05 FILLER              BINARY-LONG VALUE 7.
    05 FILLER              BINARY-LONG VALUE 10.
    05 FILLER              BINARY-LONG VALUE 10.
    05 FILLER              BINARY-LONG VALUE -8.
    05 FILLER              BINARY-LONG VALUE -9.
    05 FILLER              BINARY-LONG VALUE -7.
    05 FILLER              BINARY-LONG VALUE -8.
    05 FILLER              BINARY-LONG VALUE -10.
    05 FILLER              BINARY-LONG VALUE -7.
 01 WS-EXP-X-T REDEFINES WS-EXP-Xs.
    05 WS-EXP-X            BINARY-LONG OCCURS 14 TIMES.
 01 WS-EXP-Ys.
    05 FILLER              BINARY-LONG VALUE 64.
    05 FILLER              BINARY-LONG VALUE 63.
    05 FILLER              BINARY-LONG VALUE 62.
    05 FILLER              BINARY-LONG VALUE 63.
    05 FILLER              BINARY-LONG VALUE 61.
    05 FILLER              BINARY-LONG VALUE 63.
    05 FILLER              BINARY-LONG VALUE 61.
    05 FILLER              BINARY-LONG VALUE 63.
    05 FILLER              BINARY-LONG VALUE 64.
    05 FILLER              BINARY-LONG VALUE 63.
    05 FILLER              BINARY-LONG VALUE 61.
    05 FILLER              BINARY-LONG VALUE 61.
    05 FILLER              BINARY-LONG VALUE 63.
    05 FILLER              BINARY-LONG VALUE 61.
 01 WS-EXP-Y-T REDEFINES WS-EXP-Ys.
    05 WS-EXP-Y            BINARY-LONG OCCURS 14 TIMES.
 01 WS-EXP-Zs.
    05 FILLER              BINARY-LONG VALUE 6.
    05 FILLER              BINARY-LONG VALUE 8.
    05 FILLER              BINARY-LONG VALUE 9.
    05 FILLER              BINARY-LONG VALUE 7.
    05 FILLER              BINARY-LONG VALUE 9.
    05 FILLER              BINARY-LONG VALUE 6.
    05 FILLER              BINARY-LONG VALUE 5.
    05 FILLER              BINARY-LONG VALUE 5.
    05 FILLER              BINARY-LONG VALUE 5.
    05 FILLER              BINARY-LONG VALUE 6.
    05 FILLER              BINARY-LONG VALUE 9.
    05 FILLER              BINARY-LONG VALUE 7.
    05 FILLER              BINARY-LONG VALUE 9.
    05 FILLER              BINARY-LONG VALUE 8.
 01 WS-EXP-Z-T REDEFINES WS-EXP-Zs.
    05 WS-EXP-Z            BINARY-LONG OCCURS 14 TIMES.
 01 WS-EXP-SEEDs.
    05 FILLER              BINARY-DOUBLE VALUE 1649267466304.
    05 FILLER              BINARY-DOUBLE VALUE 2199023288383.
    05 FILLER              BINARY-DOUBLE VALUE 2199023292478.
    05 FILLER              BINARY-DOUBLE VALUE 1924145377343.
    05 FILLER              BINARY-DOUBLE VALUE 1924145385533.
    05 FILLER              BINARY-DOUBLE VALUE 1924145373247.
    05 FILLER              BINARY-DOUBLE VALUE 2748779089981.
    05 FILLER              BINARY-DOUBLE VALUE 2748779089983.
    05 FILLER              BINARY-DOUBLE VALUE -2199023235008.
    05 FILLER              BINARY-DOUBLE VALUE -2473901137857.
    05 FILLER              BINARY-DOUBLE VALUE -1924145311683.
    05 FILLER              BINARY-DOUBLE VALUE -2199023226819.
    05 FILLER              BINARY-DOUBLE VALUE -2748779032513.
    05 FILLER              BINARY-DOUBLE VALUE -1924145315779.
 01 WS-EXP-SEED-T REDEFINES WS-EXP-SEEDs.
    05 WS-EXP-SEED            BINARY-DOUBLE OCCURS 14 TIMES.
 01 WS-START              BINARY-LONG.
 01 WS-LEN                BINARY-LONG.
 01 WS-OFFS               BINARY-LONG.
 01 WS-SAND               BINARY-LONG.
 01 WS-SUSP               BINARY-LONG.
 01 WS-NSAND              BINARY-LONG.
 01 WS-NSUSP              BINARY-LONG.
 01 WS-BAD                BINARY-LONG.
 01 WS-USEED              BINARY-DOUBLE UNSIGNED VALUE 12345.
 01 WS-K                  BINARY-LONG.
 01 WS-DIRD                PIC 9.
 01 WS-NEIGH-D             PIC 9.
 01 WS-NAME                PIC X(60).
 01 WS-REST                PIC X(600).
 01 WS-NEIGH.
    05 WS-NEIGH-CASE       BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE "content/tests/fixtures/std" TO CS-GENERATED-DIR
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     ALLOCATE 304640 CHARACTERS INITIALIZED RETURNING WS-PTR
     MOVE SPACES TO WS-PAIRS WS-KEY
     MOVE "minecraft:stone" TO WS-KEY
     CALL "STRUCT-TPL-STATE" USING WS-KEY WS-PAIRS WS-STONE

*>   the swamp hut, four orientations: 141 blocks, the document's spot blocks, the rotation and mirror of the stairs
     PERFORM VARYING WS-DIR FROM 0 BY 1 UNTIL WS-DIR > 3
         MOVE WS-DIR TO WS-DIRD
         MOVE 103 TO WS-TYPE
         MOVE 7 TO WS-W
         MOVE 7 TO WS-H
         MOVE 9 TO WS-D
         MOVE 0 TO WS-X0 WS-Z0
         MOVE 0 TO WS-WCX WS-WCZ
         PERFORM MAKE-PIECE
         PERFORM OPEN-WINDOW
         MOVE 0 TO GEL-COUNT GEL-LOST
         CALL "SCP-HUT-POST" USING WS-ROW
         PERFORM COUNT-WINDOW
         MOVE SPACES TO TL-CASE
         STRING "acceptance US12 36-4§5.4 Swamp hut: orientation " WS-DIRD " asks for one witch then one cat, 2 requests" DELIMITED BY SIZE INTO TL-CASE
         MOVE 0 TO TL-OBSERVED-N
         IF GEL-COUNT = 2 AND GEL-NBT(1)(8:15) = "minecraft:witch" AND GEL-NBT(2)(8:13) = "minecraft:cat"
             MOVE 1 TO TL-OBSERVED-N
         END-IF
         MOVE 1 TO TL-EXPECTED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE SPACES TO TL-CASE
         STRING "acceptance US12 36-4§5.2 Swamp hut: orientation " WS-DIRD " writes 141 blocks" DELIMITED BY SIZE INTO TL-CASE
         MOVE 141 TO TL-EXPECTED-N
         MOVE WS-COUNT TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>       cauldron (4,2,6), crafting table (3,2,6), the red mushroom pot (1,3,5), an oak log leg (1,0,2), the leg's column top (1,-1,2)
         MOVE 4 TO WS-LX MOVE 2 TO WS-LY MOVE 6 TO WS-LZ
         MOVE "cauldron" TO WS-SPEC
         MOVE "cauldron (4,2,6)" TO WS-LABEL
         PERFORM CHECK-SPEC
         MOVE 3 TO WS-LX MOVE 2 TO WS-LY MOVE 6 TO WS-LZ
         MOVE "crafting_table" TO WS-SPEC
         MOVE "crafting table (3,2,6)" TO WS-LABEL
         PERFORM CHECK-SPEC
         MOVE 1 TO WS-LX MOVE 3 TO WS-LY MOVE 5 TO WS-LZ
         MOVE "potted_red_mushroom" TO WS-SPEC
         MOVE "potted mushroom (1,3,5)" TO WS-LABEL
         PERFORM CHECK-SPEC
         MOVE 1 TO WS-LX MOVE -1 TO WS-LY MOVE 2 TO WS-LZ
         MOVE "oak_log" TO WS-SPEC
         MOVE "leg column top (1,-1,2)" TO WS-LABEL
         PERFORM CHECK-SPEC
*>       the stair row z = 1 faces north in the local frame: south mirrors, west mirrors and turns, east turns
         MOVE 3 TO WS-LX MOVE 4 TO WS-LY MOVE 1 TO WS-LZ
         COMPUTE WS-DI = WS-DIR + 1
         MOVE SPACES TO WS-SPEC
         STRING "spruce_stairs[facing=" FUNCTION TRIM(WS-FACING-OF(WS-DI)) "]" DELIMITED BY SIZE INTO WS-SPEC
         MOVE "stair (3,4,1)" TO WS-LABEL
         PERFORM CHECK-SPEC
*>       the corner stair (0,4,1) is north facing outer_right: a mirror swaps the shape, a rotation keeps it
         MOVE 0 TO WS-LX MOVE 4 TO WS-LY MOVE 1 TO WS-LZ
         MOVE SPACES TO WS-SPEC
         STRING "spruce_stairs[facing=" FUNCTION TRIM(WS-FACING-OF(WS-DI)) ",shape="
             FUNCTION TRIM(WS-SHAPE-OF(WS-DI)) "]" DELIMITED BY SIZE INTO WS-SPEC
         MOVE "corner stair (0,4,1)" TO WS-LABEL
         PERFORM CHECK-SPEC
     END-PERFORM

*>   the jungle temple, four orientations: 1222 blocks, the containers
     PERFORM VARYING WS-DIR FROM 0 BY 1 UNTIL WS-DIR > 3
         MOVE WS-DIR TO WS-DIRD
         MOVE 102 TO WS-TYPE
         MOVE 12 TO WS-W
         MOVE 10 TO WS-H
         MOVE 15 TO WS-D
         MOVE 0 TO WS-X0 WS-Z0
         MOVE 0 TO WS-WCX WS-WCZ
         PERFORM MAKE-PIECE
         PERFORM OPEN-WINDOW
         CALL "SCP-JUNGLE-POST" USING WS-ROW
         PERFORM COUNT-WINDOW
         MOVE SPACES TO TL-CASE
         STRING "acceptance US12 36-4§4 Jungle temple: orientation " WS-DIRD " writes 1222 blocks" DELIMITED BY SIZE INTO TL-CASE
         MOVE 1222 TO TL-EXPECTED-N
         MOVE WS-COUNT TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE SPACES TO TL-CASE
         STRING "acceptance US12 36-4§4.4 Jungle temple: orientation " WS-DIRD " asks for 4 containers, all placed flags set" DELIMITED BY SIZE INTO TL-CASE
         MOVE 4 TO TL-EXPECTED-N
         MOVE 0 TO TL-OBSERVED-N
         IF GBL-COUNT = 4 AND SP-F1(WS-ROW) = 1 AND SP-F2(WS-ROW) = 1 AND SP-F3(WS-ROW) = 1 AND SP-F4(WS-ROW) = 1
             MOVE 4 TO TL-OBSERVED-N
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>       dispenser 1 (3,-2,1) faces north, dispenser 2 (9,-2,3) faces west, in the piece's frame
         MOVE 3 TO WS-LX MOVE -2 TO WS-LY MOVE 1 TO WS-LZ
         COMPUTE WS-DI = WS-DIR + 1
         MOVE SPACES TO WS-SPEC
         STRING "dispenser[facing=" FUNCTION TRIM(WS-FACING-OF(WS-DI)) "]" DELIMITED BY SIZE INTO WS-SPEC
         MOVE "dispenser 1 (3,-2,1)" TO WS-LABEL
         PERFORM CHECK-SPEC
*>       the loot tables in the order of the document: the two dispensers, then the main and the hidden chest
         MOVE SPACES TO TL-CASE
         STRING "acceptance US12 36-4§4.4 Jungle temple: orientation " WS-DIRD " loot tables in order dispenser, dispenser, chest, chest" DELIMITED BY SIZE INTO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 0 TO TL-OBSERVED-N
         IF GBL-LOOT(1) = "minecraft:chests/jungle_temple_dispenser" AND GBL-LOOT(2) = "minecraft:chests/jungle_temple_dispenser"
             AND GBL-LOOT(3) = "minecraft:chests/jungle_temple" AND GBL-LOOT(4) = "minecraft:chests/jungle_temple"
             AND GBL-KIND(1) = 1 AND GBL-SEED(1) NOT = GBL-SEED(2) AND GBL-SEED(2) NOT = GBL-SEED(3) AND GBL-SEED(3) NOT = GBL-SEED(4)
             MOVE 1 TO TL-OBSERVED-N
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>       the moss stone selector: the floor layer (y -4, 180 cells) is all cobblestone or mossy cobblestone, about 40 percent cobblestone
         MOVE "cobblestone" TO WS-SPEC
         PERFORM STATE-OF-SPEC
         MOVE WS-STATE TO WS-COBBLE
         MOVE "mossy_cobblestone" TO WS-SPEC
         PERFORM STATE-OF-SPEC
         MOVE WS-STATE TO WS-MOSSY
         MOVE 0 TO WS-COBBLES WS-OTHERS
         PERFORM VARYING WS-WX FROM 0 BY 1 UNTIL WS-WX > 15
             PERFORM VARYING WS-WZ FROM 0 BY 1 UNTIL WS-WZ > 15
                 MOVE 60 TO WS-WY
                 PERFORM CELL-AT
                 MOVE 0 TO WS-INBOX
                 IF (WS-DIR = 0 OR WS-DIR = 2) AND WS-WX < 12 AND WS-WZ < 15
                     MOVE 1 TO WS-INBOX
                 END-IF
                 IF (WS-DIR = 1 OR WS-DIR = 3) AND WS-WX < 15 AND WS-WZ < 12
                     MOVE 1 TO WS-INBOX
                 END-IF
                 EVALUATE TRUE
                     WHEN WS-CELL = WS-COBBLE AND WS-INBOX = 1
                         ADD 1 TO WS-COBBLES
                     WHEN WS-CELL = WS-MOSSY AND WS-INBOX = 1
                         ADD 1 TO WS-OTHERS
                 END-EVALUATE
             END-PERFORM
         END-PERFORM
         COMPUTE WS-COUNT2 = WS-COBBLES + WS-OTHERS
         MOVE SPACES TO TL-CASE
         STRING "acceptance US12 36-4§4.2 Jungle temple: orientation " WS-DIRD " every floor cell is cobblestone or mossy cobblestone" DELIMITED BY SIZE INTO TL-CASE
         MOVE 180 TO TL-EXPECTED-N
         MOVE WS-COUNT2 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE SPACES TO TL-CASE
         STRING "acceptance US12 36-4§4.2 Jungle temple: orientation " WS-DIRD " about 40 percent of the floor is cobblestone (the draw is below 0.4)" DELIMITED BY SIZE INTO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 0 TO TL-OBSERVED-N
         IF WS-COBBLES > 40 AND WS-COBBLES < 100
             MOVE 1 TO TL-OBSERVED-N
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM

*>   the flags make a second pass create no container
     MOVE 0 TO GBL-COUNT
     CALL "SCP-JUNGLE-POST" USING WS-ROW
     MOVE "acceptance US12 36-4§4.4 Jungle temple: a second postProcess with the flags set asks for no container" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE GBL-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   clipping: the temple at x 8 to 19 across two chunk windows adds up to the whole 1222 blocks; a window with no part of it gets nothing and no container
     MOVE 2 TO WS-DIR
     MOVE 8 TO WS-X0
     MOVE 0 TO WS-WCX WS-WCZ
     PERFORM MAKE-PIECE
     PERFORM OPEN-WINDOW
     CALL "SCP-JUNGLE-POST" USING WS-ROW
     PERFORM COUNT-WINDOW
     MOVE WS-COUNT TO WS-COUNT2
     MOVE 1 TO WS-WCX
     MOVE 0 TO SP-F1(WS-ROW) SP-F2(WS-ROW) SP-F3(WS-ROW) SP-F4(WS-ROW)
     PERFORM OPEN-WINDOW
     CALL "SCP-JUNGLE-POST" USING WS-ROW
     PERFORM COUNT-WINDOW
     ADD WS-COUNT TO WS-COUNT2
     MOVE "acceptance US12 36-1§6.5 Clipping: the temple across two chunks writes 1222 blocks in all" TO TL-CASE
     MOVE 1222 TO TL-EXPECTED-N
     MOVE WS-COUNT2 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-WCX
     MOVE 0 TO SP-F3(WS-ROW) SP-F4(WS-ROW) SP-F1(WS-ROW) SP-F2(WS-ROW)
     PERFORM OPEN-WINDOW
     CALL "SCP-JUNGLE-POST" USING WS-ROW
     PERFORM COUNT-WINDOW
     MOVE "acceptance US12 36-1§6.5 Clipping: a window outside the box gets no block, no container, and the flags stay clear" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-COUNT + GBL-COUNT + SP-F1(WS-ROW) + SP-F2(WS-ROW) + SP-F3(WS-ROW) + SP-F4(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   fillColumnDown: water on top, seagrass below, stone under: the first two are replaced by the state, the stone stops it; in an empty window the column ends at min y + 2
     MOVE 102 TO WS-TYPE MOVE 12 TO WS-W MOVE 10 TO WS-H MOVE 15 TO WS-D MOVE 2 TO WS-DIR MOVE 0 TO WS-X0 WS-Z0 WS-WCX WS-WCZ
     PERFORM MAKE-PIECE
     PERFORM OPEN-WINDOW
     MOVE "minecraft:water" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     CALL "STRUCT-TPL-STATE" USING WS-KEY WS-PAIRS WS-STATE
     MOVE 3 TO WS-WX MOVE 63 TO WS-WY MOVE 5 TO WS-WZ
     PERFORM SET-CELL
     MOVE "minecraft:seagrass" TO WS-KEY
     CALL "STRUCT-TPL-STATE" USING WS-KEY WS-PAIRS WS-STATE
     MOVE 62 TO WS-WY
     PERFORM SET-CELL
     MOVE "oak_log" TO WS-SPEC
     PERFORM STATE-OF-SPEC
     MOVE 3 TO WS-LX MOVE -1 TO WS-LY MOVE 9 TO WS-LZ
     MOVE WS-LX TO WS-LX2
     MOVE WS-LZ TO WS-LZ2
     CALL "SCP-COLUMN" USING WS-ROW WS-STATE WS-LX WS-LZ WS-LX2 WS-LZ2 WS-LY
     MOVE "acceptance US12 36-1§6.5 fillColumnDown: water and seagrass are replaced down to the stone" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     MOVE 3 TO WS-WX MOVE 63 TO WS-WY MOVE 5 TO WS-WZ
     PERFORM CELL-AT
     IF WS-CELL = WS-STATE
         MOVE 62 TO WS-WY
         PERFORM CELL-AT
         IF WS-CELL = WS-STATE
             MOVE 61 TO WS-WY
             PERFORM CELL-AT
             IF WS-CELL = WS-STONE
                 MOVE 1 TO TL-OBSERVED-N
             END-IF
         END-IF
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   an empty column in an empty window: from y 63 down to -62 (126 cells), the cell at min y + 1 = -63 is left
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 200 * 256
         MOVE 0 TO CE-STATE(WS-I)
     END-PERFORM
     MOVE 3 TO WS-LX MOVE -1 TO WS-LY MOVE 9 TO WS-LZ
     MOVE WS-LX TO WS-LX2
     MOVE WS-LZ TO WS-LZ2
     CALL "SCP-COLUMN" USING WS-ROW WS-STATE WS-LX WS-LZ WS-LX2 WS-LZ2 WS-LY
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-WY FROM -64 BY 1 UNTIL WS-WY > 70
         MOVE 3 TO WS-WX
         MOVE 5 TO WS-WZ
         PERFORM CELL-AT
         IF WS-CELL = WS-STATE
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-1§6.5 fillColumnDown: with nothing to stop it the column fills y 63 down to -62 (126 cells)" TO TL-CASE
     MOVE 126 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   a column that starts outside the write box is skipped
     MOVE 1 TO WS-WCX
     PERFORM OPEN-WINDOW
     MOVE WS-LX TO WS-LX2
     MOVE WS-LZ TO WS-LZ2
     CALL "SCP-COLUMN" USING WS-ROW WS-STATE WS-LX WS-LZ WS-LX2 WS-LZ2 WS-LY
     PERFORM COUNT-WINDOW
     MOVE "acceptance US12 36-1§6.5 fillColumnDown: a column outside the write box writes nothing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   generateBox with skipAir: air cells stay, other cells take the state
     MOVE 0 TO WS-WCX
     PERFORM OPEN-WINDOW
     MOVE 3 TO WS-WX MOVE 70 TO WS-WY MOVE 11 TO WS-WZ
     MOVE WS-STONE TO WS-STATE
     PERFORM SET-CELL
     MOVE "oak_log" TO WS-SPEC
     PERFORM STATE-OF-SPEC
     MOVE WS-STATE TO WS-FILL
     MOVE 1 TO WS-SKIP
     MOVE 3 TO WS-LX MOVE 6 TO WS-LY MOVE 3 TO WS-LZ
     MOVE 4 TO WS-X1 MOVE 4 TO WS-Z1
     MOVE 2 TO WS-LX
     MOVE WS-LY TO WS-LY2
     MOVE WS-FILL TO WS-FILL2
     CALL "SCP-BOX" USING WS-ROW WS-LX WS-LY WS-LZ WS-X1 WS-LY2 WS-Z1 WS-FILL WS-FILL2 WS-SKIP
     MOVE 3 TO WS-WX MOVE 70 TO WS-WY MOVE 11 TO WS-WZ
     PERFORM CELL-AT
     MOVE WS-CELL TO WS-COUNT
     MOVE 2 TO WS-WX MOVE 70 TO WS-WY MOVE 11 TO WS-WZ
     PERFORM CELL-AT
     MOVE "acceptance US12 36-1§6.5 generateBox skipAir: a stone cell is replaced, an air cell is left" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-COUNT = WS-FILL AND WS-CELL = 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the buried treasure (36-4 7.2): the box is the block (9, 90, 9), no orientation. Scenario 1: stone up to y 61, water west of the target, a void under the east neighbour; scenario 2: a gravel
*>   block on the stone; scenario 3: a window of air only.
     PERFORM TREASURE-PIECE
     PERFORM OPEN-WINDOW
     MOVE 10 TO WS-WX MOVE 61 TO WS-WY MOVE 9 TO WS-WZ
     MOVE 0 TO WS-STATE
     PERFORM SET-CELL
     MOVE "minecraft:water" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     CALL "STRUCT-TPL-STATE" USING WS-KEY WS-PAIRS WS-STATE
     MOVE 8 TO WS-WX MOVE 62 TO WS-WY MOVE 9 TO WS-WZ
     PERFORM SET-CELL
     CALL "SCP-TREASURE-POST" USING WS-ROW
     MOVE "sand" TO WS-SPEC
     PERFORM STATE-OF-SPEC
     MOVE WS-STATE TO WS-SAND
     MOVE 0 TO WS-BAD
     MOVE 9 TO WS-WX MOVE 63 TO WS-WY MOVE 9 TO WS-WZ
     PERFORM CELL-AT
     IF WS-CELL NOT = WS-SAND
         ADD 1 TO WS-BAD
     END-IF
     MOVE 9 TO WS-WX MOVE 62 TO WS-WY MOVE 8 TO WS-WZ
     PERFORM CELL-AT
     IF WS-CELL NOT = WS-SAND
         ADD 1 TO WS-BAD
     END-IF
     MOVE 10 TO WS-WZ
     PERFORM CELL-AT
     IF WS-CELL NOT = WS-SAND
         ADD 1 TO WS-BAD
     END-IF
     MOVE 8 TO WS-WX MOVE 9 TO WS-WZ
     PERFORM CELL-AT
     IF WS-CELL NOT = WS-SAND
         ADD 1 TO WS-BAD
     END-IF
     MOVE 10 TO WS-WX
     PERFORM CELL-AT
     IF WS-CELL NOT = WS-STONE
         ADD 1 TO WS-BAD
     END-IF
     MOVE "acceptance US12 36-4§7.2 Buried treasure: the air and water neighbours are sand, up included, the one over a void is the support block" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:chest" TO WS-KEY
     MOVE "facing=east" TO WS-PAIRS
     CALL "STRUCT-TPL-STATE" USING WS-KEY WS-PAIRS WS-WANT
     MOVE 9 TO WS-WX MOVE 62 TO WS-WY MOVE 9 TO WS-WZ
     PERFORM CELL-AT
     MOVE "acceptance US12 36-4§7.2 Buried treasure: the chest takes the first cell above stone, reoriented between four walls to east" TO TL-CASE
     MOVE WS-WANT TO TL-EXPECTED-N
     MOVE WS-CELL TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-4§7.2 Buried treasure: one chest request with the buried treasure table" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF GBL-COUNT = 1 AND GBL-LOOT(1) = "minecraft:chests/buried_treasure" AND GBL-X(1) = 9 AND GBL-Y(1) = 62 AND GBL-Z(1) = 9
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   scenario 2: gravel on the stone: the scan skips the cell above it (the block below is gravel), the fill is the gravel itself
     PERFORM OPEN-WINDOW
     MOVE "gravel" TO WS-SPEC
     PERFORM STATE-OF-SPEC
     MOVE WS-STATE TO WS-FILL
     MOVE 9 TO WS-WX MOVE 62 TO WS-WY MOVE 9 TO WS-WZ
     PERFORM SET-CELL
     CALL "SCP-TREASURE-POST" USING WS-ROW
     MOVE 0 TO WS-BAD
     MOVE 8 TO WS-WX
     PERFORM CELL-AT
     IF WS-CELL NOT = WS-FILL
         ADD 1 TO WS-BAD
     END-IF
     MOVE 9 TO WS-WX MOVE 63 TO WS-WY
     PERFORM CELL-AT
     IF WS-CELL NOT = WS-FILL
         ADD 1 TO WS-BAD
     END-IF
     MOVE 62 TO WS-WY
     PERFORM CELL-AT
     IF WS-CELL NOT = WS-WANT
         ADD 1 TO WS-BAD
     END-IF
     MOVE "acceptance US12 36-4§7.2 Buried treasure: over gravel the neighbours take the gravel and the chest replaces it" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   scenario 3: nothing but air: no stone below any cell, nothing is placed
     PERFORM OPEN-WINDOW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 126 * 256
         MOVE 0 TO CE-STATE(WS-I)
     END-PERFORM
     CALL "SCP-TREASURE-POST" USING WS-ROW
     PERFORM COUNT-WINDOW
     MOVE "acceptance US12 36-4§7.2 Buried treasure: a column with no stone writes nothing and asks for no chest" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-COUNT + GBL-COUNT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the K operation of a table (generateBox with skipAir) through SCP-RUN: the stone cell (3,70,11) takes the log, the air cell (2,70,11) stays; a P line with two positions
     MOVE 102 TO WS-TYPE MOVE 12 TO WS-W MOVE 10 TO WS-H MOVE 15 TO WS-D MOVE 2 TO WS-DIR MOVE 0 TO WS-X0 WS-Z0
     PERFORM MAKE-PIECE
     PERFORM OPEN-WINDOW
     MOVE "oak_log" TO WS-SPEC
     PERFORM STATE-OF-SPEC
     MOVE WS-STATE TO WS-FILL
     MOVE 3 TO WS-WX MOVE 70 TO WS-WY MOVE 11 TO WS-WZ
     MOVE WS-STONE TO WS-STATE
     PERFORM SET-CELL
     CALL "SCP-RUN" USING WS-ROW WS-OPS WS-OPCOUNT
     MOVE 3 TO WS-WX MOVE 70 TO WS-WY MOVE 11 TO WS-WZ
     PERFORM CELL-AT
     MOVE WS-CELL TO WS-COUNT
     MOVE 2 TO WS-WX
     PERFORM CELL-AT
     MOVE "acceptance US12 36-4§2.3 Scattered tables: a K line replaces the non-air cell and leaves the air cell" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-COUNT = WS-FILL AND WS-CELL = 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   createChest twice at one position: the second finds the chest and asks for nothing
     MOVE 0 TO GBL-COUNT
     MOVE "minecraft:chests/jungle_temple" TO WS-LOOT
     MOVE "chest" TO WS-WANT-KEY
     MOVE 6 TO WS-LX MOVE 8 TO WS-LY MOVE 6 TO WS-LZ
     CALL "SCP-CONTAINER" USING WS-ROW WS-LX WS-LY WS-LZ WS-CHEST-SPEC WS-WANT-KEY WS-LOOT WS-PLACED
     MOVE WS-PLACED TO WS-COUNT
     CALL "SCP-CONTAINER" USING WS-ROW WS-LX WS-LY WS-LZ WS-CHEST-SPEC WS-WANT-KEY WS-LOOT WS-PLACED
     MOVE "acceptance US12 36-1§6.5 createChest: the first call places, the second finds the chest and does not" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-COUNT * 10 + WS-PLACED + GBL-COUNT * 100 - 100
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   reorient of a chest: six layouts around (8, 70, 8)
     PERFORM VARYING WS-NEIGH-CASE FROM 1 BY 1 UNTIL WS-NEIGH-CASE > 6
         MOVE WS-NEIGH-CASE TO WS-NEIGH-D
         PERFORM OPEN-WINDOW
         MOVE WS-STONE TO WS-STATE
         MOVE "chest" TO WS-SPEC
         MOVE 8 TO WS-WX MOVE 70 TO WS-WY MOVE 8 TO WS-WZ
         EVALUATE WS-NEIGH-CASE
             WHEN 1
                 MOVE "facing=north" TO WS-PAIRS
             WHEN 2
*>               a wall to the north only: the chest faces south
                 MOVE 7 TO WS-WZ
                 PERFORM SET-CELL
                 MOVE "facing=south" TO WS-PAIRS
             WHEN 3
*>               walls north and south: the scan ends at the second, the fallback turns away from the north, then from the south, and ends west
                 MOVE 7 TO WS-WZ
                 PERFORM SET-CELL
                 MOVE 9 TO WS-WZ
                 PERFORM SET-CELL
                 MOVE "facing=west" TO WS-PAIRS
             WHEN 4
*>               a wall to the north and a chest to the east: the chest ends the scan, the state is unchanged
                 MOVE 7 TO WS-WZ
                 PERFORM SET-CELL
                 MOVE "minecraft:chest" TO WS-KEY
                 MOVE SPACES TO WS-PAIRS
                 CALL "STRUCT-TPL-STATE" USING WS-KEY WS-PAIRS WS-STATE
                 MOVE 9 TO WS-WX
                 MOVE 8 TO WS-WZ
                 PERFORM SET-CELL
                 MOVE "facing=north" TO WS-PAIRS
             WHEN 5
*>               a wall to the west only: the chest faces east
                 MOVE 7 TO WS-WX
                 PERFORM SET-CELL
                 MOVE "facing=east" TO WS-PAIRS
             WHEN OTHER
*>               walls north and east: two walls, the fallback turns from the north to the south and stays there
                 MOVE 7 TO WS-WZ
                 PERFORM SET-CELL
                 MOVE 9 TO WS-WX
                 MOVE 8 TO WS-WZ
                 PERFORM SET-CELL
                 MOVE "facing=south" TO WS-PAIRS
         END-EVALUATE
         MOVE "minecraft:chest" TO WS-KEY
         CALL "STRUCT-TPL-STATE" USING WS-KEY WS-PAIRS WS-WANT
         MOVE 8 TO WS-WX MOVE 70 TO WS-WY MOVE 8 TO WS-WZ
         CALL "SCP-REORIENT" USING WS-WX WS-WY WS-WZ WS-STATE
         MOVE SPACES TO TL-CASE
         STRING "acceptance US12 36-1§6.5 reorient: layout " WS-NEIGH-D " gives " FUNCTION TRIM(WS-PAIRS) DELIMITED BY SIZE INTO TL-CASE
         MOVE WS-WANT TO TL-EXPECTED-N
         MOVE WS-STATE TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
*>   the desert pyramid, north oriented at x 0 = -8 (window chunk 0, positive x) and -24 (window chunk -1, negative x: the packed seeds of the brushable blocks are negative), start random of
*>   chunk (0,0) of seed 12345; the expected values come from an independent model of the document (Java LCG, Mth.getSeed, the sorted set, Util.shuffle, pos.asLong)
     PERFORM VARYING WS-OFFS FROM 1 BY 1 UNTIL WS-OFFS > 2
         MOVE 101 TO WS-TYPE MOVE 21 TO WS-W MOVE 15 TO WS-H MOVE 21 TO WS-D MOVE 2 TO WS-DIR MOVE 0 TO WS-Z0
         IF WS-OFFS = 1
             MOVE -8 TO WS-X0
             MOVE 0 TO WS-WCX
             MOVE 1 TO WS-START
             MOVE 8 TO WS-LEN
             MOVE 99 TO WS-NSAND
             MOVE 8 TO WS-NSUSP
         ELSE
             MOVE -24 TO WS-X0
             MOVE -1 TO WS-WCX
             MOVE 9 TO WS-START
             MOVE 6 TO WS-LEN
             MOVE 102 TO WS-NSAND
             MOVE 6 TO WS-NSUSP
         END-IF
         MOVE WS-OFFS TO WS-DIRD
         MOVE 0 TO WS-WCZ
         PERFORM MAKE-PIECE
         PERFORM OPEN-WINDOW
         MOVE 12345 TO SP-SEED
         CALL "JRAND-LARGE-FEATURE-SEED" USING SP-RNG WS-USEED WS-ZERO WS-ZERO2
         CALL "SCP-RESET"
         CALL "SCP-DESERT-BODY" USING WS-ROW
         PERFORM COUNT-WINDOW
         MOVE SPACES TO TL-CASE
         STRING "acceptance US12 36-4§3.3 Desert pyramid: config " WS-DIRD " writes 1559 blocks into the window" DELIMITED BY SIZE INTO TL-CASE
         MOVE 1559 TO TL-EXPECTED-N
         MOVE WS-COUNT TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE SPACES TO TL-CASE
         STRING "acceptance US12 36-4§3.4 Desert pyramid: config " WS-DIRD " makes four chests of the desert pyramid table, flags set" DELIMITED BY SIZE INTO TL-CASE
         MOVE 4 TO TL-EXPECTED-N
         MOVE 0 TO TL-OBSERVED-N
         IF GBL-COUNT = 4 AND GBL-LOOT(1) = "minecraft:chests/desert_pyramid" AND GBL-LOOT(4) = "minecraft:chests/desert_pyramid"
             AND SP-F1(WS-ROW) = 1 AND SP-F2(WS-ROW) = 1 AND SP-F3(WS-ROW) = 1 AND SP-F4(WS-ROW) = 1
             MOVE 4 TO TL-OBSERVED-N
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         CALL "SCP-DESERT-AFTER"
         COMPUTE WS-COUNT2 = 4 + WS-LEN
         MOVE SPACES TO TL-CASE
         STRING "acceptance US12 36-4§3.5 Desert pyramid: config " WS-DIRD " afterPlace asks for the roof's and 5 to 7 suspicious blocks" DELIMITED BY SIZE INTO TL-CASE
         MOVE WS-COUNT2 TO TL-EXPECTED-N
         MOVE GBL-COUNT TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>       the requests in the order of the model: the roof position, then the shuffled set's first n; position, loot table, seed pos.asLong()
         MOVE 0 TO WS-BAD
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-LEN
             COMPUTE WS-K = WS-START + WS-I - 1
             COMPUTE WS-DI = 4 + WS-I
             IF GBL-X(WS-DI) NOT = WS-EXP-X(WS-K) OR GBL-Y(WS-DI) NOT = WS-EXP-Y(WS-K) OR GBL-Z(WS-DI) NOT = WS-EXP-Z(WS-K)
                 OR GBL-SEED(WS-DI) NOT = WS-EXP-SEED(WS-K) OR GBL-LOOT(WS-DI) NOT = "minecraft:archaeology/desert_pyramid"
                 ADD 1 TO WS-BAD
             END-IF
         END-PERFORM
         MOVE SPACES TO TL-CASE
         STRING "acceptance US12 36-4§3.5 Desert pyramid: config " WS-DIRD " the suspicious sand positions, tables and seeds equal the model" DELIMITED BY SIZE INTO TL-CASE
         MOVE 0 TO TL-EXPECTED-N
         MOVE WS-BAD TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE "sand" TO WS-SPEC
         PERFORM STATE-OF-SPEC
         MOVE WS-STATE TO WS-SAND
         MOVE "suspicious_sand" TO WS-SPEC
         PERFORM STATE-OF-SPEC
         MOVE WS-STATE TO WS-SUSP
         MOVE 0 TO WS-COUNT WS-COUNT2
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 200 * 256
             IF CE-STATE(WS-I) = WS-SAND
                 ADD 1 TO WS-COUNT
             END-IF
             IF CE-STATE(WS-I) = WS-SUSP
                 ADD 1 TO WS-COUNT2
             END-IF
         END-PERFORM
         MOVE SPACES TO TL-CASE
         STRING "acceptance US12 36-4§3.5 Desert pyramid: config " WS-DIRD " the window holds the model's sand and suspicious sand cells" DELIMITED BY SIZE INTO TL-CASE
         COMPUTE TL-EXPECTED-N = WS-NSAND * 1000 + WS-NSUSP
         COMPUTE TL-OBSERVED-N = WS-COUNT * 1000 + WS-COUNT2
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         PERFORM COUNT-WINDOW
         MOVE SPACES TO TL-CASE
         STRING "acceptance US12 36-4§3.5 Desert pyramid: config " WS-DIRD " afterPlace leaves 1559 blocks in the window" DELIMITED BY SIZE INTO TL-CASE
         MOVE 1559 TO TL-EXPECTED-N
         MOVE WS-COUNT TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>       afterPlace with the lists emptied (no pyramid was post-processed in the pass) asks for nothing
         MOVE GBL-COUNT TO WS-COUNT2
         CALL "SCP-RESET"
         CALL "SCP-DESERT-AFTER"
         MOVE SPACES TO TL-CASE
         STRING "acceptance US12 36-4§3.5 Desert pyramid: config " WS-DIRD " afterPlace after a reset asks for nothing" DELIMITED BY SIZE INTO TL-CASE
         MOVE WS-COUNT2 TO TL-EXPECTED-N
         MOVE GBL-COUNT TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
*>   afterPlace over a list with duplicates (a set collapses them) shorter than n: five entries, three distinct, every one becomes suspicious sand, and the roof's
     MOVE 0 TO WS-WCX
     PERFORM OPEN-WINDOW
     MOVE 12345 TO SP-SEED
     MOVE 5 TO SCD-COUNT
     MOVE 1 TO SCD-ROOF-SET
     MOVE 0 TO SCD-ROOF-X MOVE 70 TO SCD-ROOF-Y MOVE 0 TO SCD-ROOF-Z
     MOVE 1 TO SCD-CX(1) MOVE 70 TO SCD-CY(1) MOVE 1 TO SCD-CZ(1)
     MOVE 2 TO SCD-CX(2) MOVE 70 TO SCD-CY(2) MOVE 1 TO SCD-CZ(2)
     MOVE 1 TO SCD-CX(3) MOVE 70 TO SCD-CY(3) MOVE 1 TO SCD-CZ(3)
     MOVE 2 TO SCD-CX(4) MOVE 70 TO SCD-CY(4) MOVE 1 TO SCD-CZ(4)
     MOVE 3 TO SCD-CX(5) MOVE 70 TO SCD-CY(5) MOVE 1 TO SCD-CZ(5)
     CALL "SCP-DESERT-AFTER"
     MOVE "suspicious_sand" TO WS-SPEC
     PERFORM STATE-OF-SPEC
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 200 * 256
         IF CE-STATE(WS-I) = WS-STATE
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-4§3.5 Desert pyramid: a candidate set with duplicates collapses, a set below n is all suspicious (4 requests, 4 suspicious cells)" TO TL-CASE
     MOVE 44 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = GBL-COUNT * 10 + WS-COUNT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 TREASURE-PIECE.
*>   the buried treasure piece in row 1: the block (9, 90, 9), no orientation
     MOVE 9 TO WS-X0 WS-Z0
     MOVE 90 TO WS-WY
     MOVE 9 TO WS-X1 WS-Z1
     MOVE 90 TO WS-LY2
     CALL "SPB-RESET"
     CALL "SPB-BOX-NEW" USING WS-X0 WS-WY WS-Z0 WS-X1 WS-LY2 WS-Z1 WS-BOX
     MOVE 104 TO WS-TYPE
     MOVE -1 TO WS-DIR
     CALL "SPB-ADD" USING WS-TYPE WS-DIR WS-ZERO WS-ZERO2 WS-BOX WS-ROW.

 MAKE-PIECE.
*>   a piece of the type and orientation WS-DIR at (WS-X0, 64, WS-Z0): row 1
     CALL "SPB-RESET"
     CALL "SPB-MAKE-BOX" USING WS-X0 WS-Y64 WS-Z0 WS-DIR WS-W WS-H WS-D WS-BOX
     CALL "SPB-ADD" USING WS-TYPE WS-DIR WS-ZERO WS-ZERO2 WS-BOX WS-ROW.

 OPEN-WINDOW.
*>   the window of chunk (WS-WCX, WS-WCZ): stone up to y 61, air above; the piece random seeded; no request
     SET ADDRESS OF CE-CHUNK TO WS-PTR
     MOVE LOW-VALUES TO CE-CHUNK
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 126 * 256
         MOVE WS-STONE TO CE-STATE(WS-I)
     END-PERFORM
     CALL "FL-OPEN" USING WS-PTR WS-WCX WS-WCZ WS-MIN-Y WS-HEIGHT WS-SEA
     CALL "MSP-OPEN"
     MOVE 0 TO GBL-COUNT GBL-LOST
     CALL "WGR-SET-SEED" USING WS-XR WS-FSEED
     MOVE WX-LO TO SP-XR-LO
     MOVE WX-HI TO SP-XR-HI.

 COUNT-WINDOW.
*>   the cells that are neither air nor the stone of the filler
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 200 * 256
         IF CE-STATE(WS-I) NOT = 0 AND CE-STATE(WS-I) NOT = WS-STONE
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM.

 CELL-AT.
*>   the state of the cell (WS-WX, WS-WY, WS-WZ) of the window (chunk coordinates 0 to 15)
     COMPUTE WS-I = (WS-WY + 64) * 256 + FUNCTION MOD(WS-WZ, 16) * 16 + FUNCTION MOD(WS-WX, 16) + 1
     MOVE CE-STATE(WS-I) TO WS-CELL.

 SET-CELL.
     COMPUTE WS-I = (WS-WY + 64) * 256 + FUNCTION MOD(WS-WZ, 16) * 16 + FUNCTION MOD(WS-WX, 16) + 1
     MOVE WS-STATE TO CE-STATE(WS-I).

 STATE-OF-SPEC.
*>   the state of a spec "name[pairs]" in the unrotated frame
     MOVE SPACES TO WS-NAME WS-REST WS-PAIRS WS-KEY
     UNSTRING WS-SPEC DELIMITED BY "[" INTO WS-NAME WS-REST
     UNSTRING WS-REST DELIMITED BY "]" INTO WS-PAIRS
     STRING "minecraft:" FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO WS-KEY
     CALL "STRUCT-TPL-STATE" USING WS-KEY WS-PAIRS WS-STATE.

 CHECK-SPEC.
*>   the cell at the world position of the local (WS-LX, WS-LY, WS-LZ) of the piece in row 1 is the state of WS-SPEC (the orientation applied to the position only: the
*>   caller writes the facing already turned); the position formulas of 2.3 are written here independently of SPB-WORLD
     EVALUATE WS-DIR
         WHEN 2
             COMPUTE WS-WX = SP-X0(1) + WS-LX
             COMPUTE WS-WZ = SP-Z1(1) - WS-LZ
         WHEN 0
             COMPUTE WS-WX = SP-X0(1) + WS-LX
             COMPUTE WS-WZ = SP-Z0(1) + WS-LZ
         WHEN 1
             COMPUTE WS-WX = SP-X1(1) - WS-LZ
             COMPUTE WS-WZ = SP-Z0(1) + WS-LX
         WHEN OTHER
             COMPUTE WS-WX = SP-X0(1) + WS-LZ
             COMPUTE WS-WZ = SP-Z0(1) + WS-LX
     END-EVALUATE
     COMPUTE WS-WY = SP-Y0(1) + WS-LY
     PERFORM CELL-AT
     MOVE WS-CELL TO WS-COUNT2
     PERFORM STATE-OF-SPEC
     MOVE WS-DIR TO WS-DIRD
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 36-4§2.3 Scattered piece: orientation " WS-DIRD " " FUNCTION TRIM(WS-LABEL) " is " FUNCTION TRIM(WS-SPEC) DELIMITED BY SIZE INTO TL-CASE
     MOVE WS-STATE TO TL-EXPECTED-N
     MOVE WS-COUNT2 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-STRUCT-SCATTER.

 COPY CORETEST.
