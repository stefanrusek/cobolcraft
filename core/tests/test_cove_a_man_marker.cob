*> Coverage of the woodland mansion chest markers (docs/protocol/36-structures-7 section 7.1; core/src/struct-man-start.cob MAN-MARKER, struct-tpl-piece.cob STRUCT-DATA-MARKER): the facing of a chest marker turned by
*> a piece of rotation 0 for each of ChestNorth, ChestEast, ChestSouth and ChestWest, and the data marker of a kind-5 (mansion) template piece reaching MAN-MARKER.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVE-A-MAN-MARKER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 COPY STRUCTPIECE.
 COPY CELLS.
 COPY FEATLEVEL.
 COPY GENENT.
 01 WS-PTR                 USAGE POINTER.
 01 WS-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==A-==.
 01 WS-CX                  BINARY-LONG VALUE 0.
 01 WS-CZ                  BINARY-LONG VALUE 0.
 01 WS-MIN                 BINARY-LONG VALUE -64.
 01 WS-HEIGHT              BINARY-LONG VALUE 384.
 01 WS-SEA                 BINARY-LONG VALUE 63.
 01 WS-IDX                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(600) VALUE SPACES.
 01 WS-STONE               BINARY-LONG.
 01 WS-COBBLE              BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-PT                  BINARY-LONG VALUE 100.
 01 WS-PO                  BINARY-LONG VALUE 2.
 01 WS-DEP                 BINARY-LONG VALUE 0.
 01 WS-MST                 BINARY-LONG VALUE 0.
 01 WS-META                PIC X(96).
 01 WS-WANT                PIC X(32).
 01 WS-BX                  BINARY-LONG.
 01 WS-MODE                BINARY-LONG VALUE 1.
 01 WS-PROP                PIC X(24) VALUE "facing".
 01 WS-TEXT                PIC X(32).
 01 WS-FOUND               BINARY-LONG.
 01 WS-BEFORE-LO           BINARY-DOUBLE UNSIGNED.
 01 WS-OK                  BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-Y1                  BINARY-LONG.
 01 WS-CHEST-BLOCK         BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE "content/tests/fixtures/std" TO CS-GENERATED-DIR
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     ALLOCATE 304640 CHARACTERS INITIALIZED RETURNING WS-PTR
     CALL "SPB-RESET"
     SET ADDRESS OF CE-CHUNK TO WS-PTR
     MOVE LOW-VALUES TO CE-CHUNK
     CALL "FL-OPEN" USING WS-PTR WS-CX WS-CZ WS-MIN WS-HEIGHT WS-SEA
     CALL "MSP-OPEN"
     MOVE 5 TO SP-XR-LO
     MOVE 7 TO SP-XR-HI
     MOVE 0 TO SW-X0
     MOVE -63 TO SW-Y0
     MOVE 0 TO SW-Z0
     MOVE 15 TO SW-X1
     MOVE 319 TO SW-Y1
     MOVE 15 TO SW-Z1
     MOVE 2 TO A-X0 MOVE 60 TO A-Y0 MOVE 2 TO A-Z0 MOVE 9 TO A-X1 MOVE 70 TO A-Y1 MOVE 9 TO A-Z1
     CALL "SPB-ADD" USING WS-PT WS-PO WS-DEP WS-MST WS-BOX WS-ROW
     MOVE 5 TO SP-T-KIND(WS-ROW)
     MOVE 0 TO SP-T-ROT(WS-ROW)
     MOVE 65 TO WS-Y
     MOVE 6 TO WS-Z
     PERFORM VARYING WS-X FROM 1 BY 1 UNTIL WS-X > 4
         EVALUATE WS-X
             WHEN 1
                 MOVE "ChestNorth" TO WS-META
                 MOVE "north" TO WS-WANT
             WHEN 2
                 MOVE "ChestEast" TO WS-META
                 MOVE "east" TO WS-WANT
             WHEN 3
                 MOVE "ChestSouth" TO WS-META
                 MOVE "south" TO WS-WANT
             WHEN OTHER
                 MOVE "ChestWest" TO WS-META
                 MOVE "west" TO WS-WANT
         END-EVALUATE
         COMPUTE WS-BX = WS-X + 4
         CALL "MAN-MARKER" USING WS-ROW WS-META WS-BX WS-Y WS-Z
         CALL "FL-GET-STATE" USING WS-BX WS-Y WS-Z WS-STATE
         MOVE SPACES TO WS-TEXT
         CALL "BLOCK-STATE-PROP" USING WS-MODE WS-STATE WS-PROP WS-TEXT WS-FOUND
         MOVE SPACES TO TL-CASE
         STRING "acceptance US12 36-7§7.1 " FUNCTION TRIM(WS-META) " in a piece of rotation 0 faces " FUNCTION TRIM(WS-WANT) DELIMITED BY SIZE INTO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 0 TO TL-OBSERVED-N
         IF WS-FOUND = 1 AND WS-TEXT = WS-WANT
             MOVE 1 TO TL-OBSERVED-N
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
*>   the data marker of a template piece of kind 5 is the mansion's
     MOVE "ChestEast" TO WS-META
     MOVE 9 TO WS-BX
     CALL "STRUCT-DATA-MARKER" USING WS-ROW WS-META WS-BX WS-Y WS-Z
     CALL "FL-GET-STATE" USING WS-BX WS-Y WS-Z WS-STATE
     MOVE SPACES TO WS-TEXT
     CALL "BLOCK-STATE-PROP" USING WS-MODE WS-STATE WS-PROP WS-TEXT WS-FOUND
     MOVE "acceptance US12 36-7§7.1 a ChestEast data marker of a kind-5 piece places an east-facing chest" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-FOUND = 1 AND WS-TEXT = "east"
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-COVE-A-MAN-MARKER.

 COPY CORETEST.
