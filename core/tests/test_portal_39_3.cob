*> Implementation test (T1749; docs/protocol/39-portals.md section 3): the nether portal frame. PORTAL-FIND-SHAPE (3.2: bottom-left walk,
*> edge distance, width 2 to 21, height 3 to 21 with frame posts, empty interior and a frame top row), fire placed in an empty valid shape
*> fills it with nether_portal blocks of its axis (3.3, only in the overworld and the nether), and a change next to a portal block that
*> leaves its shape incomplete turns it into air (3.4). Frames are built in the nether (the placeholder generator); needs the generated
*> packs (a pass without them).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PORTAL-39-3.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY PORTALSHAPE.
 01 WS-SKIP                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-AXIS                BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-FIRE                BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-KEY-FIRE            PIC X(48) VALUE "fire".
 01 WS-KEY-STONE           PIC X(48) VALUE "stone".
 01 WS-KEY-PORTAL          PIC X(48) VALUE "nether_portal".
 01 WS-PAIRS-NONE          PIC X(160) VALUE SPACES.
 01 WS-PAIRS-Z             PIC X(160) VALUE "axis=z".
 01 WS-PORTAL-X            BINARY-LONG.
 01 WS-PORTAL-Z            BINARY-LONG.
 01 WS-A                   PIC -(9)9.
 01 WS-B                   PIC -(9)9.
 01 WS-C                   PIC -(9)9.
 01 WS-D                   PIC -(9)9.
 01 WS-E                   PIC -(9)9.
 01 WS-F                   PIC -(9)9.
 01 WS-G                   PIC -(9)9.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "PT-OPEN" USING WS-SKIP
     IF WS-SKIP = 1
         MOVE "N" TO TL-MODE
         MOVE "acceptance US12 39§3 The nether portal frame: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     MOVE DIM-STANDARD-NETHER TO WS-DIM
     CALL "PT-STATE" USING WS-KEY-FIRE WS-PAIRS-NONE WS-FIRE
     CALL "PT-STATE" USING WS-KEY-STONE WS-PAIRS-NONE WS-STONE
     CALL "PT-STATE" USING WS-KEY-PORTAL WS-PAIRS-NONE WS-PORTAL-X
     CALL "PT-STATE" USING WS-KEY-PORTAL WS-PAIRS-Z WS-PORTAL-Z

*>   E1: obsidian x 0..3, y 64..68, z 0, interior (1..2, 65..67): found from the fire cell (1, 65, 0).
     MOVE 2 TO WS-X MOVE 65 TO WS-Y MOVE 0 TO WS-Z
     MOVE 0 TO WS-AXIS
     MOVE 2 TO WS-W
     MOVE 3 TO WS-H
     CALL "PT-FRAME" USING WS-DIM WS-X WS-Y WS-Z WS-AXIS WS-W WS-H
     MOVE 1 TO WS-X
     CALL "PORTAL-FIND-SHAPE" USING WS-DIM WS-X WS-Y WS-Z WS-AXIS PORTAL-SHAPE
     MOVE "acceptance US12 39§3 The nether portal frame: E1 a 2 x 3 frame is found from an interior cell as axis X, "
         & "width 2, height 3, no portal blocks, bottom-left (2, 65, 0)" TO TL-CASE
     PERFORM SHAPE-TEXT
     MOVE "1 0 2 3 0 2 65 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 39§3 The nether portal frame: E1 fire placed at (1, 65, 0) turns the six interior cells "
         & "into nether_portal axis X (flags 18: no shape update undoes them)" TO TL-CASE
     CALL "BLOCK-CHANGE" USING WS-DIM WS-X WS-Y WS-Z WS-FIRE
     MOVE 2 TO WS-X
     CALL "PT-PORTALS" USING WS-DIM WS-X WS-Y WS-Z WS-AXIS WS-W WS-H WS-COUNT
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE WS-COUNT TO WS-A
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-A) " " DELIMITED BY SIZE INTO TL-OBSERVED
     IF WS-STATE = WS-PORTAL-X
         STRING FUNCTION TRIM(TL-OBSERVED) " x" DELIMITED BY SIZE INTO TL-OBSERVED
     ELSE
         STRING FUNCTION TRIM(TL-OBSERVED) " other" DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     MOVE "6 x" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 39§3 The nether portal frame: a lit shape is found again as complete (count = width x height)" TO TL-CASE
     MOVE 1 TO WS-X
     CALL "PORTAL-FIND-SHAPE" USING WS-DIM WS-X WS-Y WS-Z WS-AXIS PORTAL-SHAPE
     PERFORM SHAPE-TEXT
     MOVE "1 0 2 3 6 2 65 0" TO TL-EXPECTED
     PERFORM CHECK

*>   Axis Z: right is SOUTH, the bottom-left cell is the northmost interior cell.
     MOVE 20 TO WS-X MOVE 65 TO WS-Y MOVE 2 TO WS-Z
     MOVE 1 TO WS-AXIS
     MOVE 2 TO WS-W
     MOVE 3 TO WS-H
     CALL "PT-FRAME" USING WS-DIM WS-X WS-Y WS-Z WS-AXIS WS-W WS-H
     MOVE 3 TO WS-Z
     CALL "BLOCK-CHANGE" USING WS-DIM WS-X WS-Y WS-Z WS-FIRE
     MOVE 2 TO WS-Z
     CALL "PT-PORTALS" USING WS-DIM WS-X WS-Y WS-Z WS-AXIS WS-W WS-H WS-COUNT
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE WS-COUNT TO WS-A
     MOVE SPACES TO TL-OBSERVED
     IF WS-STATE = WS-PORTAL-Z
         STRING FUNCTION TRIM(WS-A) " z" DELIMITED BY SIZE INTO TL-OBSERVED
     ELSE
         STRING FUNCTION TRIM(WS-A) " other" DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     MOVE "acceptance US12 39§3 The nether portal frame: a frame along Z is lit as nether_portal axis Z" TO TL-CASE
     MOVE "6 z" TO TL-EXPECTED
     PERFORM CHECK

*>   E2 rejections: height 2, width 1, bottom row missing its obsidian, a gap in the top row, width 22.
     MOVE SPACES TO TL-OBSERVED
     MOVE 0 TO WS-AXIS
     MOVE 2 TO WS-W
     MOVE 2 TO WS-H
     MOVE 2 TO WS-X MOVE 65 TO WS-Y MOVE 10 TO WS-Z
     CALL "PT-FRAME" USING WS-DIM WS-X WS-Y WS-Z WS-AXIS WS-W WS-H
     MOVE 1 TO WS-X
     CALL "PORTAL-FIND-SHAPE" USING WS-DIM WS-X WS-Y WS-Z WS-AXIS PORTAL-SHAPE
     MOVE PQ-VALID TO WS-A
     MOVE 1 TO WS-W
     MOVE 3 TO WS-H
     MOVE 2 TO WS-X MOVE 12 TO WS-Z
     CALL "PT-FRAME" USING WS-DIM WS-X WS-Y WS-Z WS-AXIS WS-W WS-H
     CALL "PORTAL-FIND-SHAPE" USING WS-DIM WS-X WS-Y WS-Z WS-AXIS PORTAL-SHAPE
     MOVE PQ-VALID TO WS-B
     MOVE 2 TO WS-W
     MOVE 2 TO WS-X MOVE 14 TO WS-Z
     CALL "PT-FRAME" USING WS-DIM WS-X WS-Y WS-Z WS-AXIS WS-W WS-H
     COMPUTE WS-Y = 64
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-AIR
     MOVE 65 TO WS-Y
     CALL "PORTAL-FIND-SHAPE" USING WS-DIM WS-X WS-Y WS-Z WS-AXIS PORTAL-SHAPE
     MOVE PQ-VALID TO WS-C
     MOVE 2 TO WS-X MOVE 16 TO WS-Z
     CALL "PT-FRAME" USING WS-DIM WS-X WS-Y WS-Z WS-AXIS WS-W WS-H
     MOVE 1 TO WS-X MOVE 68 TO WS-Y
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-AIR
     MOVE 65 TO WS-Y
     CALL "PORTAL-FIND-SHAPE" USING WS-DIM WS-X WS-Y WS-Z WS-AXIS PORTAL-SHAPE
     MOVE PQ-VALID TO WS-D
     MOVE 22 TO WS-W
     MOVE 3 TO WS-H
     MOVE 3 TO WS-X MOVE 50 TO WS-Y MOVE 60 TO WS-Z
     CALL "PT-FRAME" USING WS-DIM WS-X WS-Y WS-Z WS-AXIS WS-W WS-H
     MOVE 51 TO WS-Y
     CALL "PORTAL-FIND-SHAPE" USING WS-DIM WS-X WS-Y WS-Z WS-AXIS PORTAL-SHAPE
     MOVE PQ-VALID TO WS-E
     STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) " " FUNCTION TRIM(WS-C) " " FUNCTION TRIM(WS-D) " "
         FUNCTION TRIM(WS-E) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US12 39§3 The nether portal frame: E2 height 2, width 1, a bottom cell without obsidian, "
         & "a gap in the top row and width 22 are no shape" TO TL-CASE
     MOVE "0 0 0 0 0" TO TL-EXPECTED
     PERFORM CHECK

*>   The largest sizes: 21 wide and 3 high, and 2 wide and 21 high, each lit completely by one fire.
     MOVE 21 TO WS-W
     MOVE 3 TO WS-H
     MOVE 3 TO WS-X MOVE 50 TO WS-Y MOVE 80 TO WS-Z
     CALL "PT-FRAME" USING WS-DIM WS-X WS-Y WS-Z WS-AXIS WS-W WS-H
     MOVE 1 TO WS-X MOVE 51 TO WS-Y
     CALL "BLOCK-CHANGE" USING WS-DIM WS-X WS-Y WS-Z WS-FIRE
     MOVE 3 TO WS-X MOVE 50 TO WS-Y
     CALL "PT-PORTALS" USING WS-DIM WS-X WS-Y WS-Z WS-AXIS WS-W WS-H WS-COUNT
     MOVE WS-COUNT TO WS-A
     MOVE 2 TO WS-W
     MOVE 21 TO WS-H
     MOVE 3 TO WS-X MOVE 50 TO WS-Y MOVE 90 TO WS-Z
     CALL "PT-FRAME" USING WS-DIM WS-X WS-Y WS-Z WS-AXIS WS-W WS-H
     MOVE 2 TO WS-X MOVE 60 TO WS-Y
     CALL "BLOCK-CHANGE" USING WS-DIM WS-X WS-Y WS-Z WS-FIRE
     MOVE 3 TO WS-X MOVE 50 TO WS-Y
     CALL "PT-PORTALS" USING WS-DIM WS-X WS-Y WS-Z WS-AXIS WS-W WS-H WS-COUNT
     MOVE WS-COUNT TO WS-B
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US12 39§3 The nether portal frame: the maximum width 21 x 3 and the maximum height 2 x 21 "
         & "are lit completely (63 and 42 blocks)" TO TL-CASE
     MOVE "63 42" TO TL-EXPECTED
     PERFORM CHECK

*>   Fire in a valid frame in the end does nothing: no portal blocks, the fire stays.
     MOVE DIM-STANDARD-END TO WS-DIM
     MOVE 2 TO WS-W
     MOVE 3 TO WS-H
     MOVE 102 TO WS-X MOVE 60 TO WS-Y MOVE 10 TO WS-Z
     CALL "PT-FRAME" USING WS-DIM WS-X WS-Y WS-Z WS-AXIS WS-W WS-H
     MOVE 101 TO WS-X
     CALL "BLOCK-CHANGE" USING WS-DIM WS-X WS-Y WS-Z WS-FIRE
     MOVE 102 TO WS-X
     CALL "PT-PORTALS" USING WS-DIM WS-X WS-Y WS-Z WS-AXIS WS-W WS-H WS-COUNT
     MOVE 101 TO WS-X
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE WS-COUNT TO WS-A
     MOVE SPACES TO TL-OBSERVED
     IF WS-STATE = WS-FIRE
         STRING FUNCTION TRIM(WS-A) " fire" DELIMITED BY SIZE INTO TL-OBSERVED
     ELSE
         STRING FUNCTION TRIM(WS-A) " other" DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     MOVE "acceptance US12 39§3 The nether portal frame: 3.3 fire in a valid frame in the end lights nothing" TO TL-CASE
     MOVE "0 fire" TO TL-EXPECTED
     PERFORM CHECK

*>   3.4 destruction. The first lit portal (x 1..2, y 65..67, z 0): a block across the plane keeps it, a stone in the interior or a
*>   removed frame post dissolves it.
     MOVE DIM-STANDARD-NETHER TO WS-DIM
     MOVE 0 TO WS-AXIS
     MOVE 2 TO WS-W
     MOVE 3 TO WS-H
     MOVE 1 TO WS-X MOVE 66 TO WS-Y MOVE 1 TO WS-Z
     CALL "BLOCK-CHANGE" USING WS-DIM WS-X WS-Y WS-Z WS-STONE
     MOVE 2 TO WS-X MOVE 65 TO WS-Y MOVE 0 TO WS-Z
     CALL "PT-PORTALS" USING WS-DIM WS-X WS-Y WS-Z WS-AXIS WS-W WS-H WS-COUNT
     MOVE WS-COUNT TO WS-A
     MOVE SPACES TO TL-OBSERVED
     MOVE FUNCTION TRIM(WS-A) TO TL-OBSERVED
     MOVE "acceptance US12 39§3 The nether portal frame: 3.4 a block placed across the portal plane leaves the six blocks" TO TL-CASE
     MOVE "6" TO TL-EXPECTED
     PERFORM CHECK

     MOVE 3 TO WS-X MOVE 66 TO WS-Y MOVE 0 TO WS-Z
     CALL "BLOCK-CHANGE" USING WS-DIM WS-X WS-Y WS-Z WS-AIR
     MOVE 2 TO WS-X MOVE 65 TO WS-Y
     CALL "PT-PORTALS" USING WS-DIM WS-X WS-Y WS-Z WS-AXIS WS-W WS-H WS-COUNT
     MOVE WS-COUNT TO WS-A
     MOVE SPACES TO TL-OBSERVED
     MOVE FUNCTION TRIM(WS-A) TO TL-OBSERVED
     MOVE "acceptance US12 39§3 The nether portal frame: 3.4 breaking a frame post removes every portal block of the shape" TO TL-CASE
     MOVE "0" TO TL-EXPECTED
     PERFORM CHECK

*>   A second shape (the Z frame): a stone placed in its interior dissolves the rest.
     MOVE 1 TO WS-AXIS
     MOVE 20 TO WS-X MOVE 65 TO WS-Y MOVE 3 TO WS-Z
     CALL "BLOCK-CHANGE" USING WS-DIM WS-X WS-Y WS-Z WS-STONE
     MOVE 2 TO WS-Z
     CALL "PT-PORTALS" USING WS-DIM WS-X WS-Y WS-Z WS-AXIS WS-W WS-H WS-COUNT
     MOVE WS-COUNT TO WS-A
     MOVE SPACES TO TL-OBSERVED
     MOVE FUNCTION TRIM(WS-A) TO TL-OBSERVED
     MOVE "acceptance US12 39§3 The nether portal frame: 3.4 a stone put into the interior leaves no portal block" TO TL-CASE
     MOVE "0" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

*> The shape as "valid axis width height count bottom-left x y z".
 SHAPE-TEXT.
     MOVE PQ-VALID TO WS-A
     MOVE PQ-AXIS TO WS-B
     MOVE PQ-W TO WS-C
     MOVE PQ-H TO WS-D
     MOVE PQ-COUNT TO WS-E
     MOVE PQ-BX TO WS-F
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) " " FUNCTION TRIM(WS-C) " " FUNCTION TRIM(WS-D) " "
         FUNCTION TRIM(WS-E) " " FUNCTION TRIM(WS-F) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE PQ-BY TO WS-A
     MOVE PQ-BZ TO WS-B
     STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) DELIMITED BY SIZE
         INTO TL-OBSERVED.

 CHECK.
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-PORTAL-39-3.

 COPY CORETEST.
 COPY PORTALTEST.
