*> Acceptance test, lane try6fix (operator report: placing a door placed only the bottom half, and each half could be broken alone; 24 part 1
*> sections 5 and 10, property half = lower or upper): a standard world opened from the generated vanilla data pack (CC_GENERATED_DIR, default
*> /tmp/cc-test/generated; skipped as a pass without it). Alice uses an oak_door on the top face of a stone block: the lower half is placed
*> above it and the upper half above that; with the upper cell taken nothing is placed; breaking the upper half in survival removes both halves
*> and leaves one door item (the loot of the lower half); breaking the lower half in creative removes both and leaves no item. The break time of
*> the door is set to 0 in the core's block table so that Start Digging breaks it at once (T6401).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-DOOR-STANDARD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY CBLOCKS.
 01 WS-DIR                 PIC X(1024).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-IID                 BINARY-LONG.
 01 WS-BID                 BINARY-LONG.
 01 WS-IROW                PIC X(270).
 01 WS-BROW                PIC X(819).
 01 WS-STATUS              BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-X                   BINARY-LONG VALUE 0.
 01 WS-Y                   BINARY-LONG VALUE 200.
 01 WS-Y1                  BINARY-LONG VALUE 201.
 01 WS-Y2                  BINARY-LONG VALUE 202.
 01 WS-Y3                  BINARY-LONG VALUE 203.
 01 WS-Z                   BINARY-LONG VALUE 0.
 01 WS-FACE                BINARY-LONG VALUE 1.
 01 WS-SEQ                 BINARY-LONG VALUE 0.
 01 WS-ACTION              BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-VOID                BINARY-LONG VALUE 0.
 01 WS-PROP-MODE           BINARY-LONG VALUE 1.
 01 WS-PROP-NAME           PIC X(24) VALUE "half".
 01 WS-PROP-TEXT           PIC X(32).
 01 WS-PROP-RESULT         BINARY-LONG.
 01 WS-HALF1               PIC X(8).
 01 WS-HALF2               PIC X(8).
 01 WS-ITEMS               PIC 9.
 01 WS-COUNT               PIC 9.
 01 WS-I                   BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-ENV = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-DIR
     ELSE
         MOVE WS-ENV TO WS-DIR
     END-IF
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-DIR TRAILING) "/vanilla-data/pack.mcmeta" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE NOT = 0
         MOVE "N" TO TL-MODE
         MOVE "acceptance door standard no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 0 TO CS-DEFAULT-MODE
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS
     MOVE "12345" TO CS-SEED-TEXT
     MOVE "Doors" TO CS-NEW-WORLD-NAME
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-ROW
     MOVE PL-DIM(WS-ROW) TO WS-DIM
*>   A column in the chunk the player stands in (the spawn of a standard world is far from the origin), above any terrain.
     COMPUTE WS-X = FUNCTION INTEGER(EN-X(PL-ENTITY-ROW(WS-ROW)))
     COMPUTE WS-Z = FUNCTION INTEGER(EN-Z(PL-ENTITY-ROW(WS-ROW)))
     MOVE "stone" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BID WS-BROW WS-STATUS
     MOVE CB-DEFAULT-STATE(WS-BID + 1) TO WS-STONE
     MOVE "oak_door" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BID WS-BROW WS-STATUS
     MOVE 0 TO CB-BREAK-MS(WS-BID + 1)
     MOVE "oak_door" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-IID WS-IROW WS-STATUS
     MOVE WS-IID TO PL-SLOT-ITEM(WS-ROW, 1)
     MOVE 5 TO PL-SLOT-COUNT(WS-ROW, 1)
     MOVE 0 TO PL-SLOT-VAR(WS-ROW, 1)
     MOVE 0 TO PL-HELD(WS-ROW)

     MOVE "acceptance door standard: a door used on the floor has its lower and upper half, one door less" TO TL-CASE
     PERFORM CLEAR-COLUMN
     PERFORM PLACE-DOOR
     PERFORM CHECK-COLUMN
     MOVE "lower upper 4" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance door standard: breaking the upper half in survival removes both halves, one door item lies there" TO TL-CASE
     MOVE 0 TO PL-MODE(WS-ROW)
     MOVE WS-Y2 TO WS-I
     PERFORM START-DIG
     PERFORM CHECK-COLUMN
     MOVE "void void 1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance door standard: a door used under a taken cell (stone two above the floor) is not placed" TO TL-CASE
     PERFORM CLEAR-COLUMN
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y2 WS-Z WS-STONE
     PERFORM PLACE-DOOR
     PERFORM CHECK-COLUMN
     MOVE "void stone 5" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance door standard: breaking the lower half in creative removes both halves, no item" TO TL-CASE
     PERFORM CLEAR-COLUMN
     PERFORM PLACE-DOOR
     MOVE 1 TO PL-MODE(WS-ROW)
     MOVE WS-Y1 TO WS-I
     PERFORM START-DIG
     PERFORM CHECK-COLUMN
     MOVE "void void 0" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

*> A stone floor at y 200 with air above, no ground items, Alice survival with 5 doors held.
 CLEAR-COLUMN.
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STONE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y1 WS-Z WS-VOID
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y2 WS-Z WS-VOID
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y3 WS-Z WS-VOID
     MOVE 0 TO PL-MODE(WS-ROW)
     MOVE 5 TO PL-SLOT-COUNT(WS-ROW, 1)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-PLAYER(WS-I) = 0
             MOVE 0 TO EN-USED(WS-I)
         END-IF
     END-PERFORM.

 PLACE-DOOR.
     ADD 1 TO WS-SEQ
     CALL "TEST-USE-ON" USING WS-CONN WS-X WS-Y WS-Z WS-FACE WS-SEQ.

*> Start Digging on the cell at height WS-I.
 START-DIG.
     MOVE 0 TO WS-ACTION
     ADD 1 TO WS-SEQ
     CALL "TEST-ACTION" USING WS-CONN WS-ACTION WS-X WS-I WS-Z WS-FACE WS-SEQ.

*> WS-TEXT of the check: the half of the cells at y 201 and 202 ("void", "stone" or the half), and the ground items.
 CHECK-COLUMN.
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y1 WS-Z WS-STATE
     PERFORM HALF-OF
     MOVE WS-PROP-TEXT TO WS-HALF1
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y2 WS-Z WS-STATE
     PERFORM HALF-OF
     MOVE WS-PROP-TEXT TO WS-HALF2
     MOVE 0 TO WS-I
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0 AND EN-ITEM-COUNT(WS-I) > 0
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM
     MOVE PL-SLOT-COUNT(WS-ROW, 1) TO WS-ITEMS.

 HALF-OF.
     MOVE "void" TO WS-PROP-TEXT
     IF WS-STATE NOT = 0
         MOVE "stone" TO WS-PROP-TEXT
         CALL "BLOCK-STATE-PROP" USING WS-PROP-MODE WS-STATE WS-PROP-NAME WS-PROP-TEXT WS-PROP-RESULT
         IF WS-PROP-RESULT = 0
             MOVE "stone" TO WS-PROP-TEXT
         END-IF
     END-IF.

*> The expected text is "<half 101> <half 102> <doors held, or the ground items after a break>".
 CHECK.
     MOVE SPACES TO TL-OBSERVED
     IF TL-CASE(27:8) = "breaking"
         STRING FUNCTION TRIM(WS-HALF1) " " FUNCTION TRIM(WS-HALF2) " " WS-COUNT DELIMITED BY SIZE INTO TL-OBSERVED
     ELSE
         STRING FUNCTION TRIM(WS-HALF1) " " FUNCTION TRIM(WS-HALF2) " " WS-ITEMS DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-DOOR-STANDARD.

 COPY CORETEST.
