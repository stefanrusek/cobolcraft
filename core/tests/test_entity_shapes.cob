*> Implementation test (lane bugbed, operator report of try16: "mobs stand on beds as if they are full blocks"; docs/protocol/51 block shapes, 41 section 3 item motion, 18 section 3.2
*> mob motion): ground items and mobs rest on the collision shape of a block, not on its whole cell. In the standard set: a bed (0.5625 high), a path block and farmland
*> (0.9375), soul sand (0.875), a bottom slab (0.5) and a full block (1.0) each hold a falling ground item at that height above the cell; ENTITY-BOX-HITS-Y reports
*> the shape's height as the top, a box above the shape does not hit; a zombie lands on a bed at 0.5625 and, walking into the side of a bed from the floor, steps up exactly
*> the height of the bed (not a whole block).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTITY-SHAPES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY CITEMS.
 COPY CBLOCKS.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-BID                 BINARY-LONG.
 01 WS-BROW                PIC X(819).
 01 WS-EROW                PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG VALUE 100.
 01 WS-BZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ-LOCAL            BINARY-LONG.
 01 WS-STEP-X              BINARY-LONG.
 01 WS-STEP-Z              BINARY-LONG.
 01 WS-YB                  BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ITEM-ROW            BINARY-LONG OCCURS 6 TIMES.
 01 WS-ZOMBIE-TYPE         BINARY-LONG.
 01 WS-ZOMBIE              BINARY-LONG.
 01 WS-ITEM                BINARY-LONG VALUE 2.
 01 WS-COUNT               BINARY-LONG VALUE 1.
 01 WS-DELAY               BINARY-LONG VALUE 32767.
 01 WS-N                   BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-V1                  FLOAT-LONG VALUE 0.
 01 WS-V2                  FLOAT-LONG VALUE 0.
 01 WS-V3                  FLOAT-LONG VALUE 0.
 01 WS-HX                  FLOAT-LONG.
 01 WS-HZ                  FLOAT-LONG VALUE 0.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-HIT                 BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-TOP-Y               FLOAT-LONG.
 01 WS-SHOW                BINARY-LONG.
 01 WS-KEYS.
    05 FILLER PIC X(16) VALUE "red_bed".
    05 FILLER PIC X(16) VALUE "dirt_path".
    05 FILLER PIC X(16) VALUE "soul_sand".
    05 FILLER PIC X(16) VALUE "stone".
    05 FILLER PIC X(16) VALUE "oak_slab".
    05 FILLER PIC X(16) VALUE "farmland".
 01 WS-KEY-TABLE REDEFINES WS-KEYS.
    05 WS-SHAPE-KEY        PIC X(16) OCCURS 6 TIMES.
*> The height of the top face above the cell, in ten thousandths of a block.
 01 WS-HEIGHTS.
    05 FILLER PIC 9(5) VALUE 5625.
    05 FILLER PIC 9(5) VALUE 9375.
    05 FILLER PIC 9(5) VALUE 8750.
    05 FILLER PIC 9(5) VALUE 10000.
    05 FILLER PIC 9(5) VALUE 5000.
    05 FILLER PIC 9(5) VALUE 9375.
 01 WS-HEIGHT-TABLE REDEFINES WS-HEIGHTS.
    05 WS-EXPECT-H         PIC 9(5) OCCURS 6 TIMES.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-STANDARD-TABLES"
     CALL "BR-WORLD-READY"
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-PX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-CX = WS-PX + 4
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     MOVE "N" TO TL-MODE
*>   Six blocks in a row two apart, high in the air: a ground item falls on each.
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
         MOVE SPACES TO WS-KEY
         STRING "minecraft:" FUNCTION TRIM(WS-SHAPE-KEY(WS-K)) DELIMITED BY SIZE INTO WS-KEY
         CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BID WS-BROW WS-STATUS
         COMPUTE WS-BX = WS-CX + WS-K * 2
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ CB-DEFAULT-STATE(WS-BID + 1)
         COMPUTE WS-X = WS-BX + 0.5
         MOVE 104 TO WS-Y
         COMPUTE WS-Z = WS-BZ + 0.5
         CALL "GI-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-V1 WS-V2 WS-V3 WS-ITEM WS-COUNT WS-DELAY WS-ITEM-ROW(WS-K)
     END-PERFORM
     MOVE 60 TO WS-N
     CALL "TEST-TICKS" USING WS-N
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
         MOVE SPACES TO TL-CASE
         STRING "test entity shapes: a ground item falling on " FUNCTION TRIM(WS-SHAPE-KEY(WS-K)) " rests at the height of its shape"
             DELIMITED BY SIZE INTO TL-CASE
         COMPUTE WS-SHOW = FUNCTION INTEGER(EN-Y(WS-ITEM-ROW(WS-K)) * 10000 + 0.5) - WS-BY * 10000
         MOVE WS-EXPECT-H(WS-K) TO TL-EXPECTED-N
         MOVE WS-SHOW TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
*>   The query itself: a box in the bed's cell hits and reports the bed's top; a box above the bed does not; a box beside it does not.
     COMPUTE WS-BX = WS-CX + 2
     COMPUTE WS-X = WS-BX + 0.5
     COMPUTE WS-Y = WS-BY + 0.3
     COMPUTE WS-Z = WS-BZ + 0.5
     CALL "ENTITY-BOX-HITS-Y" USING WS-DIM CR-LOOSE-ITEM WS-X WS-Y WS-Z WS-HIT WS-TOP WS-TOP-Y
     MOVE "test entity shapes: a box in the lower part of a bed hits" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-HIT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test entity shapes: the bed's top face is 0.5625 above its cell" TO TL-CASE
     MOVE 5625 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER((WS-TOP-Y - WS-BY) * 10000 + 0.5)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test entity shapes: the cell of the top is the bed's cell" TO TL-CASE
     MOVE WS-BY TO TL-EXPECTED-N
     MOVE WS-TOP TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-Y = WS-BY + 0.6
     CALL "ENTITY-BOX-HITS-Y" USING WS-DIM CR-LOOSE-ITEM WS-X WS-Y WS-Z WS-HIT WS-TOP WS-TOP-Y
     MOVE "test entity shapes: a box above the bed's top face does not hit" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-HIT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-BOX-HITS" USING WS-DIM CR-LOOSE-ITEM WS-X WS-Y WS-Z WS-HIT WS-TOP
     MOVE "test entity shapes: ENTITY-BOX-HITS agrees (no hit above the bed)" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-Y = WS-BY + 0.3
     CALL "ENTITY-BOX-HITS" USING WS-DIM CR-LOOSE-ITEM WS-X WS-Y WS-Z WS-HIT WS-TOP
     MOVE "test entity shapes: ENTITY-BOX-HITS agrees (a hit in the bed)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-HIT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A zombie falls onto the bed and stands on it.
     MOVE "minecraft:zombie" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ZOMBIE-TYPE WS-EROW WS-STATUS
     COMPUTE WS-Y = WS-BY + 3
     CALL "MOB-SPAWN" USING WS-DIM WS-ZOMBIE-TYPE WS-X WS-Y WS-Z WS-YAW WS-ZOMBIE
     MOVE 0 TO WS-HX
     PERFORM 40 TIMES
         CALL "MOB-PHYSICS" USING WS-ZOMBIE WS-HX WS-HZ WS-YAW
     END-PERFORM
     MOVE "test entity shapes: a zombie falling onto a bed stands at 0.5625 above it" TO TL-CASE
     MOVE 5625 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER((EN-Y(WS-ZOMBIE) - WS-BY) * 10000 + 0.5)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A zombie on a floor walks into the side of a bed: it steps up onto it (to its top, not a block higher).
     MOVE "minecraft:stone" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BID WS-BROW WS-STATUS
     COMPUTE WS-BX = WS-PX - 5
     COMPUTE WS-CZ-LOCAL = WS-BZ + 6
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-CZ-LOCAL CB-DEFAULT-STATE(WS-BID + 1)
     MOVE "minecraft:red_bed" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BID WS-BROW WS-STATUS
     COMPUTE WS-STEP-X = WS-BX + 1
     COMPUTE WS-YB = WS-BY + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-STEP-X WS-YB WS-CZ-LOCAL CB-DEFAULT-STATE(WS-BID + 1)
     COMPUTE WS-X = WS-BX + 0.5
     COMPUTE WS-Y = WS-BY + 1
     COMPUTE WS-Z = WS-CZ-LOCAL + 0.5
     CALL "MOB-SPAWN" USING WS-DIM WS-ZOMBIE-TYPE WS-X WS-Y WS-Z WS-YAW WS-ZOMBIE
     PERFORM 3 TIMES
         MOVE 0 TO WS-HX
         CALL "MOB-PHYSICS" USING WS-ZOMBIE WS-HX WS-HZ WS-YAW
     END-PERFORM
     MOVE 0.3 TO WS-HX
     PERFORM 5 TIMES
         CALL "MOB-PHYSICS" USING WS-ZOMBIE WS-HX WS-HZ WS-YAW
     END-PERFORM
     MOVE "test entity shapes: a zombie walking into a bed steps onto it, 0.5625 above the floor" TO TL-CASE
     MOVE 15625 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER((EN-Y(WS-ZOMBIE) - WS-BY) * 10000 + 0.5)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test entity shapes: and has moved over the bed's cell" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-X(WS-ZOMBIE) > WS-STEP-X
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The same into the side of a bed along z (the step-up of the z move).
     COMPUTE WS-BX = WS-PX - 5
     COMPUTE WS-CZ-LOCAL = WS-BZ + 12
     MOVE "minecraft:stone" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BID WS-BROW WS-STATUS
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-CZ-LOCAL CB-DEFAULT-STATE(WS-BID + 1)
     MOVE "minecraft:red_bed" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BID WS-BROW WS-STATUS
     COMPUTE WS-STEP-Z = WS-CZ-LOCAL + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-YB WS-STEP-Z CB-DEFAULT-STATE(WS-BID + 1)
     COMPUTE WS-X = WS-BX + 0.5
     COMPUTE WS-Y = WS-BY + 1
     COMPUTE WS-Z = WS-CZ-LOCAL + 0.5
     CALL "MOB-SPAWN" USING WS-DIM WS-ZOMBIE-TYPE WS-X WS-Y WS-Z WS-YAW WS-ZOMBIE
     MOVE 0 TO WS-HX
     PERFORM 3 TIMES
         CALL "MOB-PHYSICS" USING WS-ZOMBIE WS-HX WS-HZ WS-YAW
     END-PERFORM
     MOVE 0 TO WS-HX
     MOVE 0.3 TO WS-HZ
     PERFORM 5 TIMES
         CALL "MOB-PHYSICS" USING WS-ZOMBIE WS-HX WS-HZ WS-YAW
     END-PERFORM
     MOVE "test entity shapes: a zombie walking into a bed along z steps onto it, 0.5625 above the floor" TO TL-CASE
     MOVE 15625 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER((EN-Y(WS-ZOMBIE) - WS-BY) * 10000 + 0.5)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-ENTITY-SHAPES.

 COPY CORETEST.
