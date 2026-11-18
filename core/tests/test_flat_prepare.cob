*> Implementation test (superflat lane; docs/protocol/56-superflat-world.md sections 2.4 and 4.6): the expanded layers of the flat settings and the height
*> queries over a hand-made block table (no generated packs): FLAT-SETTINGS-PREPARE gives each layer cell its default state and its kind (0 = not motion
*> blocking: the layer is nulled; 1 fluid; 2 solid; the block tag of the content set is not open here, so CB-SOLID decides), an unknown block is air; the voidGen
*> flag; FLAT-BASE-HEIGHT scans from min(total - 1, 319) down and skips null layers (so the snow layer is skipped); FLAT-SPAWN-HEIGHT is -64 + min(total, 384);
*> a settings record nobody filled gets the default on first use.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FLAT-PREPARE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CBLOCKS.
 COPY FLATSET.
 01 WS-I                   BINARY-LONG.
 01 WS-ORD                 BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-NUM                 PIC -(9)9.
 01 WS-TEXT                PIC X(200).
 01 WS-PTR                 BINARY-LONG.
 01 WS-DIGIT               PIC 9.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
*>   the table: block 1 air (state 0), 2 stone (1), 3 snow (2, no collision here), 4 water (3), 5 bedrock (4)
     MOVE 5 TO CB-BLOCK-COUNT CB-STATE-COUNT
     MOVE 77777 TO CB-EPOCH
     MOVE "air" TO CB-KEY(1)
     MOVE 3 TO CB-KEY-LENGTH(1)
     MOVE "stone" TO CB-KEY(2)
     MOVE 5 TO CB-KEY-LENGTH(2)
     MOVE "snow" TO CB-KEY(3)
     MOVE 4 TO CB-KEY-LENGTH(3)
     MOVE "water" TO CB-KEY(4)
     MOVE 5 TO CB-KEY-LENGTH(4)
     MOVE "bedrock" TO CB-KEY(5)
     MOVE 7 TO CB-KEY-LENGTH(5)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         COMPUTE CB-DEFAULT-STATE(WS-I) = WS-I - 1
         COMPUTE CB-S-BLOCK(WS-I) = WS-I - 1
         MOVE 0 TO CB-SOLID(WS-I)
     END-PERFORM
     MOVE 1 TO CB-SOLID(2) CB-SOLID(5)

     MOVE 1 TO FS-LOADED
     MOVE 0 TO FS-PENDING
     MOVE 6 TO FS-LAYER-COUNT
     MOVE "minecraft:bedrock" TO FS-L-KEY(1)
     MOVE 1 TO FS-L-HEIGHT(1)
     MOVE "minecraft:stone" TO FS-L-KEY(2)
     MOVE 2 TO FS-L-HEIGHT(2)
     MOVE "minecraft:water" TO FS-L-KEY(3)
     MOVE 2 TO FS-L-HEIGHT(3)
     MOVE "minecraft:snow" TO FS-L-KEY(4)
     MOVE 1 TO FS-L-HEIGHT(4)
     MOVE "minecraft:air" TO FS-L-KEY(5)
     MOVE 3 TO FS-L-HEIGHT(5)
     MOVE "minecraft:nope" TO FS-L-KEY(6)
     MOVE 1 TO FS-L-HEIGHT(6)
     MOVE 10 TO FS-TOTAL
     MOVE -1 TO FS-STAMP
     CALL "FLAT-SETTINGS-PREPARE"
     CALL "FLAT-SETTINGS-PREPARE"
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
         MOVE FS-KIND(WS-I) TO WS-DIGIT
         STRING WS-DIGIT DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
     END-PERFORM
     MOVE "test flat prepare the kinds of ten layer cells: solid, solid, solid, fluid, fluid, then snow, air and the unknown block null" TO TL-CASE
     MOVE "2221100000" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
         MOVE FS-STATE(WS-I) TO WS-DIGIT
         STRING WS-DIGIT DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
     END-PERFORM
     MOVE "test flat prepare the states of the ten cells are the default states (0 for air and the unknown block)" TO TL-CASE
     MOVE "4113320000" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test flat prepare a stack with blocks is not void (voidGen 0)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE FS-VOID TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   heights over that stack (the water at index 4 and the snow at 5 are above the stone at 2; the snow is null)
     MOVE 0 TO WS-ORD
     CALL "FLAT-BASE-HEIGHT" USING WS-ORD WS-H
     MOVE "test flat prepare WORLD_SURFACE_WG is above the water (null snow skipped): -59" TO TL-CASE
     MOVE WS-H TO TL-OBSERVED-N
     MOVE -59 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-ORD
     CALL "FLAT-BASE-HEIGHT" USING WS-ORD WS-H
     MOVE "test flat prepare OCEAN_FLOOR_WG ignores the water: above the stone, -61" TO TL-CASE
     MOVE WS-H TO TL-OBSERVED-N
     MOVE -61 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-ORD
     CALL "FLAT-BASE-HEIGHT" USING WS-ORD WS-H
     MOVE "test flat prepare MOTION_BLOCKING counts the water: -59" TO TL-CASE
     MOVE WS-H TO TL-OBSERVED-N
     MOVE -59 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "FLAT-SPAWN-HEIGHT" USING WS-H
     MOVE "test flat prepare the spawn height counts every layer cell, null ones too: -64 + 10 = -54" TO TL-CASE
     MOVE WS-H TO TL-OBSERVED-N
     MOVE -54 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   a stack of air only is void; nothing satisfies a height test (min y), the spawn height is above its one cell
     MOVE 1 TO FS-LAYER-COUNT
     MOVE "minecraft:air" TO FS-L-KEY(1)
     MOVE 1 TO FS-L-HEIGHT(1)
     MOVE 1 TO FS-TOTAL
     MOVE -1 TO FS-STAMP
     CALL "FLAT-SETTINGS-PREPARE"
     MOVE 0 TO WS-ORD
     CALL "FLAT-BASE-HEIGHT" USING WS-ORD WS-H
     MOVE "test flat prepare an all-air stack is void and has the height min y (-64)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-H * 10 + FS-VOID
     MOVE -639 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "FLAT-SPAWN-HEIGHT" USING WS-H
     MOVE "test flat prepare the spawn height of the one air cell is -63" TO TL-CASE
     MOVE WS-H TO TL-OBSERVED-N
     MOVE -63 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   a stack taller than the dimension: only 384 cells exist, the height query starts at 319 (56 section 4.6), the spawn height is -64 + 384
     MOVE 1 TO FS-LAYER-COUNT
     MOVE "minecraft:stone" TO FS-L-KEY(1)
     MOVE 400 TO FS-L-HEIGHT(1)
     MOVE 400 TO FS-TOTAL
     MOVE -1 TO FS-STAMP
     MOVE 2 TO WS-ORD
     CALL "FLAT-BASE-HEIGHT" USING WS-ORD WS-H
     MOVE "test flat prepare a stack of 400 stone: the query is capped at index 319, height 256" TO TL-CASE
     MOVE WS-H TO TL-OBSERVED-N
     MOVE 256 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "FLAT-SPAWN-HEIGHT" USING WS-H
     MOVE "test flat prepare the spawn height of 400 layers is -64 + 384 = 320" TO TL-CASE
     MOVE WS-H TO TL-OBSERVED-N
     MOVE 320 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   no layers: nothing to find
     MOVE 0 TO FS-LAYER-COUNT FS-TOTAL
     MOVE -1 TO FS-STAMP
     MOVE 0 TO WS-ORD
     CALL "FLAT-BASE-HEIGHT" USING WS-ORD WS-H
     MOVE "test flat prepare an empty layer list has the height min y" TO TL-CASE
     MOVE WS-H TO TL-OBSERVED-N
     MOVE -64 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   a record nobody filled gets the default (bedrock 1, dirt 2, grass_block 1 from the world preset flat) on first use
     MOVE 0 TO FS-LOADED
     CALL "FLAT-SPAWN-HEIGHT" USING WS-H
     MOVE "test flat prepare the spawn height asks the default when no settings are loaded: -60" TO TL-CASE
     MOVE WS-H TO TL-OBSERVED-N
     MOVE -60 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO FS-LOADED
     CALL "FLAT-SETTINGS-PREPARE"
     MOVE "test flat prepare preparing with no settings loaded fills the default (4 layers cells)" TO TL-CASE
     MOVE FS-TOTAL TO TL-OBSERVED-N
     MOVE 4 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-FLAT-PREPARE.

 COPY CORETEST.
