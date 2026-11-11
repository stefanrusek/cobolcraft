*> Acceptance test, US4-2 (spec US4 scenario 2; tasks T433; standin-content §1.3; 09 §3.2 rows 0x42,
*> 0x08, 0x04, 0x31): a creative player holding a block item uses place on a face; the block appears
*> in the void position next to that face in its default state, and a cardstack takes the axis of
*> the clicked face (top/bottom y, east/west x, north/south z; punched false). Blocks are placed in
*> the open air at y 100 (the clicked block need not be there).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US4-PLACE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-FACE                BINARY-LONG.
 01 WS-SEQ                 BINARY-LONG VALUE 0.
 01 WS-STATE               BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-EDIT                PIC -(9)9.
 01 WS-PTR                 BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-ROW
     MOVE 2 TO PL-SLOT-ITEM(WS-ROW, 1)
     MOVE 64 TO PL-SLOT-COUNT(WS-ROW, 1)
     MOVE 6 TO PL-SLOT-ITEM(WS-ROW, 2)
     MOVE 64 TO PL-SLOT-COUNT(WS-ROW, 2)

     MOVE "acceptance US4-2 given a held greystone item when place is used on the top face of "
         & "(10, 99, 10) then greystone (state 2) appears at (10, 100, 10), the player is sent "
         & "Block Update, the Light Update of chunk (0, 0) and Block Changed Ack" TO TL-CASE
     MOVE 10 TO WS-X WS-Z
     MOVE 99 TO WS-Y
     MOVE 1 TO WS-FACE
     PERFORM USE-AND-LIST
     MOVE 100 TO WS-Y
     PERFORM ADD-STATE
     MOVE "49(0,0) 8(10,100,10=2) 4(1) state 2" TO TL-EXPECTED
     PERFORM CHECK

     MOVE 1 TO WS-STATE
     CALL "TEST-HELD" USING WS-CONN WS-STATE
     CALL "TEST-DRAIN-BLOCKS" USING WS-CONN WS-TEXT

     MOVE "acceptance US4-2 given a held cardstack when place is used on the top or bottom face "
         & "then the cardstack is placed with axis y, punched false (state 9)" TO TL-CASE
     MOVE 16 TO WS-X WS-Z
     MOVE 101 TO WS-Y
     MOVE 0 TO WS-FACE
     PERFORM USE-AND-LIST
     MOVE 12 TO WS-X WS-Z
     MOVE 99 TO WS-Y
     MOVE 1 TO WS-FACE
     PERFORM USE-AND-LIST
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR
     MOVE 100 TO WS-Y
     PERFORM ADD-STATE
     MOVE 16 TO WS-X WS-Z
     PERFORM ADD-STATE
     MOVE 12 TO WS-X WS-Z
     MOVE "state 9 state 9" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US4-2 given a held cardstack when place is used on the east or west face "
         & "then the cardstack is placed with axis x, punched false (state 7)" TO TL-CASE
     MOVE 100 TO WS-Y
     MOVE 5 TO WS-FACE
     PERFORM USE-AND-LIST
     MOVE 4 TO WS-FACE
     PERFORM USE-AND-LIST
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR
     MOVE 13 TO WS-X
     PERFORM ADD-STATE
     MOVE 11 TO WS-X
     PERFORM ADD-STATE
     MOVE "state 7 state 7" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US4-2 given a held cardstack when place is used on the north or south "
         & "face then the cardstack is placed with axis z, punched false (state 11)" TO TL-CASE
     MOVE 12 TO WS-X
     MOVE 2 TO WS-FACE
     PERFORM USE-AND-LIST
     MOVE 3 TO WS-FACE
     PERFORM USE-AND-LIST
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR
     MOVE 11 TO WS-Z
     PERFORM ADD-STATE
     MOVE 13 TO WS-Z
     PERFORM ADD-STATE
     MOVE "state 11 state 11" TO TL-EXPECTED
     PERFORM CHECK

     MOVE 0 TO WS-STATE
     CALL "TEST-HELD" USING WS-CONN WS-STATE
     MOVE "acceptance US4-2 given a held block item when place is used on a glowtube then the "
         & "block is placed against it and the glowtube keeps its state (standin §1.3)" TO TL-CASE
     MOVE 8 TO WS-X WS-Z
     MOVE 59 TO WS-Y
     MOVE 1 TO WS-FACE
     PERFORM USE-AND-LIST
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR
     PERFORM ADD-STATE
     MOVE 60 TO WS-Y
     PERFORM ADD-STATE
     MOVE "state 13 state 2" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

*> Use Item On (WS-X, WS-Y, WS-Z) face WS-FACE with the next sequence; the drained packets are
*> described in WS-TEXT (WS-PTR after them).
 USE-AND-LIST.
     ADD 1 TO WS-SEQ
     CALL "TEST-USE-ON" USING WS-CONN WS-X WS-Y WS-Z WS-FACE WS-SEQ
     CALL "TEST-DRAIN-BLOCKS" USING WS-CONN WS-TEXT
     MOVE 1 TO WS-PTR
     INSPECT WS-TEXT TALLYING WS-PTR FOR CHARACTERS BEFORE INITIAL "   ".

*> Appends " state <n>" (no leading space when WS-TEXT is empty) for the block at WS-X, WS-Y, WS-Z.
 ADD-STATE.
     CALL "TEST-BLOCK-AT" USING WS-X WS-Y WS-Z WS-STATE
     MOVE WS-STATE TO WS-EDIT
     IF WS-PTR > 1
         STRING " " DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR
     END-IF
     STRING "state " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR.

 CHECK.
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US4-PLACE.

 COPY CORETEST.
