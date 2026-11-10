*> Implementation test of the remaining Use Item On and Player Action rules (core/src/blocks.cob,
*> core/src/light.cob LIGHT-SET-BLOCK; tasks T458): the off hand does nothing; Use Item On a goto_pad
*> places nothing whatever is held (travel is US12); Player Actions other than 0, 2 and 3 (and the
*> throws 4 and 5, core/src/ground-items.cob) are not answered; a change next to a chunk that is loaded but not lit sends Light Update only for the lit
*> chunks. Alice is creative holding greystone; view distance 2.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BLOCKS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-X                   BINARY-LONG VALUE 20.
 01 WS-Y                   BINARY-LONG VALUE 99.
 01 WS-Z                   BINARY-LONG VALUE 20.
 01 WS-FACE                BINARY-LONG VALUE 1.
 01 WS-SEQ                 BINARY-LONG VALUE 0.
 01 WS-NUM                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-CX                  BINARY-LONG VALUE 3.
 01 WS-CZ                  BINARY-LONG VALUE 0.
 01 WS-ROW                 BINARY-LONG.
 01 WS-HALF                FLOAT-SHORT VALUE 0.5.
 01 WS-TEXT                PIC X(1024).
 01 WS-EDIT                PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE 2 TO PL-SLOT-ITEM(CN-PLAYER(WS-CONN), 1)
     MOVE 64 TO PL-SLOT-COUNT(CN-PLAYER(WS-CONN), 1)

     MOVE "test blocks Use Item On with the off hand places nothing: only Block Changed Ack"
         TO TL-CASE
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE 66 TO WS-NUM
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-NUM
     MOVE 1 TO WS-NUM
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-NUM
     CALL "PB-PUT-POSITION" USING PB-BUFFER WS-X WS-Y WS-Z
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-FACE
     CALL "PB-PUT-FLOAT" USING PB-BUFFER WS-HALF
     CALL "PB-PUT-FLOAT" USING PB-BUFFER WS-HALF
     CALL "PB-PUT-FLOAT" USING PB-BUFFER WS-HALF
     MOVE 0 TO WS-NUM
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-NUM
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-NUM
     MOVE 1 TO WS-SEQ
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-SEQ
     CALL "TEST-FEED-BUFFER" USING WS-CONN PB-BUFFER
     PERFORM LIST-AND-STATE
     MOVE "4(1) state 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test blocks Use Item On a goto_pad with a block item held places nothing: only Block "
         & "Changed Ack" TO TL-CASE
     MOVE 16 TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE 2 TO WS-SEQ
     CALL "TEST-USE-ON" USING WS-CONN WS-X WS-Y WS-Z WS-FACE WS-SEQ
     PERFORM LIST-AND-STATE
     MOVE "4(2) state 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test blocks Player Action 7 (swap item with offhand) swaps the held slot with the off-hand "
         & "and places no block" TO TL-CASE
     MOVE 7 TO WS-NUM
     MOVE 3 TO WS-SEQ
     CALL "TEST-ACTION" USING WS-CONN WS-NUM WS-X WS-Y WS-Z WS-FACE WS-SEQ
     PERFORM LIST-AND-STATE
     MOVE "20(2,36=0x0) 20(2,45=2x64) state 0" TO TL-EXPECTED
     PERFORM CHECK
*>   The second swap puts the held stack back for the placement below.
     CALL "TEST-ACTION" USING WS-CONN WS-NUM WS-X WS-Y WS-Z WS-FACE WS-SEQ
     CALL "TEST-DRAIN-BLOCKS" USING WS-CONN WS-TEXT

     MOVE "test blocks a block placed in chunk (2, 0) next to the loaded but unlit chunk (3, 0) "
         & "sends Light Update for the lit chunk only" TO TL-CASE
     CALL "WORLD-FIND" USING WS-DIM WS-CX WS-CZ WS-ROW
     MOVE 47 TO WS-X
     MOVE 8 TO WS-Z
     MOVE 4 TO WS-SEQ
     CALL "TEST-USE-ON" USING WS-CONN WS-X WS-Y WS-Z WS-FACE WS-SEQ
     PERFORM LIST-AND-STATE
     IF WS-ROW = 0 OR CK-LIT(WS-ROW) NOT = 0
         MOVE "chunk (3, 0) was not loaded and unlit" TO TL-OBSERVED
     END-IF
     MOVE "8(47,100,8=2) 49(2,0) 4(4) state 2" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

*> Drains the connection into WS-TEXT and appends the state of (WS-X, WS-Y + 1, WS-Z).
 LIST-AND-STATE.
     CALL "TEST-DRAIN-BLOCKS" USING WS-CONN WS-TEXT
     ADD 1 TO WS-Y
     CALL "TEST-BLOCK-AT" USING WS-X WS-Y WS-Z WS-STATE
     SUBTRACT 1 FROM WS-Y
     MOVE WS-STATE TO WS-EDIT
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-TEXT) " state " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE
         INTO TL-OBSERVED
     MOVE FUNCTION TRIM(TL-OBSERVED) TO TL-OBSERVED.

 CHECK.
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-BLOCKS.

 COPY CORETEST.
