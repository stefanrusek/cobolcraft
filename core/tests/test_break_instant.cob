*> Test of the break of a block with hardness 0 (13 section 2.1: the progress per tick is speed / hardness, so a hardness of 0 breaks
*> at once; torches, mushrooms, grass, flowers and sugar cane; operator report of try6: "cannot break blocks that have no collision").
*> BLOCK-ACTION refused every block whose break time was 0, as it did the void and the unbreakable ones. Cases: survival and
*> creative break such a block with Start Digging alone (the block becomes void, survival leaves its item), the void and a block
*> of hardness -1 stay as they are. The hardness of the block of state 2 is set in the core's block table.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BREAK-INSTANT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-X                   BINARY-LONG VALUE 20.
 01 WS-Y                   BINARY-LONG VALUE 100.
 01 WS-Z                   BINARY-LONG VALUE 20.
 01 WS-FACE                BINARY-LONG VALUE 1.
 01 WS-SEQ                 BINARY-LONG VALUE 0.
 01 WS-ACTION              BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-SET                 BINARY-LONG.
 01 WS-ITEMS               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ES                 PIC 9.
 01 WS-EI                 PIC 9.
 01 WS-TEXT                PIC X(1024).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-DEFAULT-MODE
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE 16001 TO CW-TIME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-ROW
     MOVE 2 TO WS-SET
     COMPUTE WS-BLOCK = CB-S-BLOCK(WS-SET + 1) + 1
     MOVE 0 TO CB-BREAK-MS(WS-BLOCK)

     MOVE "test break instant 13 section 2.1 survival: a block of hardness 0 is void after Start Digging alone, and its item lies there"
         TO TL-CASE
     MOVE 0 TO PL-MODE(WS-ROW)
     PERFORM BREAK-AT-ONCE
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     MOVE "state 0 items 1" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test break instant 13 section 2.4 creative: a block of hardness 0 is void after Start Digging, no item"
         TO TL-CASE
     MOVE 1 TO PL-MODE(WS-ROW)
     PERFORM BREAK-AT-ONCE
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     MOVE "state 0 items 0" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test break instant 13 section 2.4 survival: the void (state 0) stays void and drops nothing" TO TL-CASE
     MOVE 0 TO PL-MODE(WS-ROW)
     MOVE 0 TO WS-SET
     PERFORM BREAK-AT-ONCE
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     MOVE "state 0 items 0" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test break instant 13 section 2.1 survival: a block of hardness -1 is never broken" TO TL-CASE
     MOVE 2 TO WS-SET
     MOVE -1 TO CB-BREAK-MS(WS-BLOCK)
     PERFORM BREAK-AT-ONCE
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     MOVE "state 2 items 0" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> Puts WS-SET at the cell, sends Start Digging and sets WS-TEXT to "state <n> items <ground items>".
 BREAK-AT-ONCE.
     MOVE WS-SET TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         MOVE 0 TO EN-USED(WS-I)
     END-PERFORM
     MOVE 0 TO WS-ACTION
     ADD 1 TO WS-SEQ
     CALL "TEST-ACTION" USING WS-CONN WS-ACTION WS-X WS-Y WS-Z WS-FACE WS-SEQ
     CALL "TEST-BLOCK-AT" USING WS-X WS-Y WS-Z WS-STATE
     MOVE 0 TO WS-ITEMS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0 AND EN-ITEM-COUNT(WS-I) > 0
             ADD 1 TO WS-ITEMS
         END-IF
     END-PERFORM
     MOVE WS-STATE TO WS-ES
     MOVE WS-ITEMS TO WS-EI
     MOVE SPACES TO WS-TEXT
     STRING "state " WS-ES " items " WS-EI DELIMITED BY SIZE INTO WS-TEXT.
 END PROGRAM TEST-BREAK-INSTANT.

 COPY CORETEST.
