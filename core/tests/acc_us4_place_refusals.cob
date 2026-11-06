*> Acceptance test, US4 edge cases of placement (spec US4 edge "a position that is not empty, outside
*> the dimension's height range, or where it would overlap any player"; tasks T434; standin-content
*> §1.3; data-model §3): nothing is placed, the player is sent Block Changed Ack (with Block Update of
*> the real state when the position is in the height range), and in survival the held item is not
*> used up. Alice is a first-time survival player holding the starting greystone (slot 0, 64).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US4-PLACE-REFUSALS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-BOB                 BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-FACE                BINARY-LONG.
 01 WS-SEQ                 BINARY-LONG VALUE 0.
 01 WS-STATE               BINARY-LONG.
 01 WS-MOVE                BINARY-LONG VALUE 30.
 01 WS-FX                  FLOAT-LONG VALUE 30.5.
 01 WS-FY                  FLOAT-LONG VALUE 100.0.
 01 WS-FZ                  FLOAT-LONG VALUE 30.5.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-PITCH               FLOAT-SHORT VALUE 0.
 01 WS-FLAGS               BINARY-LONG VALUE 0.
 01 WS-TEXT                PIC X(1024).
 01 WS-EDIT                PIC -(9)9.
 01 WS-PTR                 BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-DEFAULT-MODE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Alice" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE "Bobby" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-BOB
     CALL "TEST-MOVE" USING WS-BOB WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     CALL "TEST-DRAIN-BLOCKS" USING WS-CONN WS-TEXT
     MOVE SPACES TO WS-TEXT
     MOVE CN-PLAYER(WS-CONN) TO WS-ROW
     MOVE 20 TO WS-X WS-Z
     MOVE 100 TO WS-Y
     MOVE 15 TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE

     MOVE "acceptance US4 edge given a target position that is not void when place is used "
         & "then nothing is placed, the player gets Block Update of the real block and Block "
         & "Changed Ack, and the survival stack is not used up" TO TL-CASE
     MOVE 99 TO WS-Y
     MOVE 1 TO WS-FACE
     PERFORM USE-AND-LIST
     MOVE 100 TO WS-Y
     PERFORM ADD-STATE
     MOVE "8(20,100,20=15) 4(1) slot 0 2x64 state 15" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US4 edge given a target above the dimension's height range (y 256) when "
         & "place is used then nothing is placed and only Block Changed Ack is sent" TO TL-CASE
     MOVE 255 TO WS-Y
     MOVE 1 TO WS-FACE
     PERFORM USE-AND-LIST
     MOVE "4(2) slot 0 2x64" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US4 edge given a target below the dimension's height range (y -1) when "
         & "place is used then nothing is placed and only Block Changed Ack is sent" TO TL-CASE
     MOVE 0 TO WS-Y
     MOVE 0 TO WS-FACE
     PERFORM USE-AND-LIST
     MOVE "4(3) slot 0 2x64" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US4 edge given a target overlapping the placing player's own box when "
         & "place is used then nothing is placed and the survival stack is not used up" TO TL-CASE
     MOVE 4 TO WS-X
     MOVE 54 TO WS-Y
     MOVE 8 TO WS-Z
     PERFORM ADD-STATE
     MOVE 53 TO WS-Y
     MOVE 1 TO WS-FACE
     PERFORM USE-AND-LIST
     MOVE 54 TO WS-Y
     PERFORM ADD-STATE
     MOVE "state 0 8(4,54,8=0) 4(4) slot 0 2x64 state 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US4 edge given a target overlapping another player's box when place is "
         & "used then nothing is placed" TO TL-CASE
     MOVE 30 TO WS-X WS-Z
     MOVE 100 TO WS-Y
     MOVE 0 TO WS-FACE
     ADD 1 TO WS-Y
     PERFORM USE-AND-LIST
     MOVE 100 TO WS-Y
     PERFORM ADD-STATE
     MOVE "8(30,100,30=0) 4(5) slot 0 2x64 state 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US4 edge given those refusals then the container state id is unchanged "
         & "(1, from the join)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE PL-STATE-ID(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> Use Item On (WS-X, WS-Y, WS-Z) face WS-FACE with the next sequence; WS-TEXT gets the drained
*> packets (appended after any text already there), then " slot 0 <item>x<count>".
 USE-AND-LIST.
     ADD 1 TO WS-SEQ
     CALL "TEST-USE-ON" USING WS-CONN WS-X WS-Y WS-Z WS-FACE WS-SEQ
     MOVE 1 TO WS-PTR
     INSPECT WS-TEXT TALLYING WS-PTR FOR CHARACTERS BEFORE INITIAL "   "
     IF WS-PTR > 1
         CALL "TEST-DRAIN-BLOCKS" USING WS-CONN TL-OBSERVED
         STRING " " FUNCTION TRIM(TL-OBSERVED) DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR
     ELSE
         CALL "TEST-DRAIN-BLOCKS" USING WS-CONN WS-TEXT
         MOVE 1 TO WS-PTR
         INSPECT WS-TEXT TALLYING WS-PTR FOR CHARACTERS BEFORE INITIAL "   "
     END-IF
     MOVE PL-SLOT-ITEM(WS-ROW, 1) TO WS-EDIT
     STRING " slot 0 " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR
     MOVE PL-SLOT-COUNT(WS-ROW, 1) TO WS-EDIT
     STRING "x" FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR.

*> Appends " state <n>" (no leading space when WS-TEXT is empty) for the block at WS-X, WS-Y, WS-Z.
 ADD-STATE.
     MOVE 1 TO WS-PTR
     INSPECT WS-TEXT TALLYING WS-PTR FOR CHARACTERS BEFORE INITIAL "   "
     CALL "TEST-BLOCK-AT" USING WS-X WS-Y WS-Z WS-STATE
     MOVE WS-STATE TO WS-EDIT
     IF WS-PTR > 1
         STRING " " DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR
     END-IF
     STRING "state " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR.

*> Compares WS-TEXT with TL-EXPECTED and clears WS-TEXT.
 CHECK.
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO WS-TEXT.
 END PROGRAM ACC-US4-PLACE-REFUSALS.

 COPY CORETEST.
