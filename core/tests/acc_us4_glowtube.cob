*> Acceptance test, US4-5 core half (spec US4 scenario 5; tasks T447; standin-content §1.1, §1.3,
*> §5.2; 09 §3.2 Block Update and Light Update rows, §3.4 rule 3): place used on a glowtube without a
*> held block item toggles lit, and the light around it is recomputed and sent. The marker glowtube of
*> the spawn chunk is at (8, 59, 8); its Light Update for chunk (0, 0) after being toggled off is the
*> fixture play-s2c-31-light-update.hex. The creative player Alice has an empty inventory.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US4-GLOWTUBE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 COPY CELLS.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-X                   BINARY-LONG VALUE 8.
 01 WS-Y                   BINARY-LONG VALUE 59.
 01 WS-Z                   BINARY-LONG VALUE 8.
 01 WS-CX                  BINARY-LONG VALUE 0.
 01 WS-CZ                  BINARY-LONG VALUE 0.
 01 WS-FACE                BINARY-LONG VALUE 2.
 01 WS-SEQ                 BINARY-LONG VALUE 0.
 01 WS-STATE               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-CLOSE               BINARY-LONG.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-PATH                PIC X(256).
 01 WS-TEXT                PIC X(1024).
 01 WS-EDIT                PIC -(9)9.
 01 WS-NUM                 BINARY-LONG.
 01 WS-CELLN               BINARY-LONG.
 01 WS-BYTE                BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-INIT" USING PK-BUFFER WS-CAPACITY
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN

     MOVE "acceptance US4-5 given no held block item when place is used on a lit glowtube then "
         & "it becomes unlit (state 14): Block Update, the Light Updates of the chunks whose "
         & "light changed, Block Changed Ack" TO TL-CASE
     PERFORM USE-ON
     CALL "TEST-DRAIN-BLOCKS" USING WS-CONN WS-TEXT
     PERFORM ADD-STATE
     MOVE "8(8,59,8=14) 49(0,-1) 49(-1,0) 49(0,0) 49(1,0) 49(0,1) 4(1) state 14"
         TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US4-5 given the glowtube toggled off then the block light around it is 0 "
         & "(the cell above it)" TO TL-CASE
     MOVE "N" TO TL-MODE
     CALL "WORLD-FIND" USING WS-DIM WS-CX WS-CZ WS-ROW
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-ROW)
     MOVE 0 TO TL-EXPECTED-N
     PERFORM ABOVE-LIGHT
     MOVE WS-NUM TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US4-5 given no held block item when place is used on the unlit glowtube "
         & "then it is lit again (state 13) and the cell above it has block light 14" TO TL-CASE
     PERFORM USE-ON
     CALL "TEST-DRAIN-BLOCKS" USING WS-CONN WS-TEXT
     CALL "TEST-BLOCK-AT" USING WS-X WS-Y WS-Z WS-STATE
     PERFORM ABOVE-LIGHT
     COMPUTE TL-OBSERVED-N = WS-STATE * 100 + WS-NUM
     MOVE 1314 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US4-5 given the glowtube toggled off when the player is sent the Light "
         & "Update of chunk (0, 0) then it equals play-s2c-31-light-update.hex" TO TL-CASE
     PERFORM USE-ON
     CALL "PB-RESET" USING PB-BUFFER
     CALL "TEST-DRAIN" USING WS-CONN PB-BUFFER WS-CLOSE
     MOVE 0 TO WS-OUTCOME WS-FOUND
     PERFORM UNTIL WS-OUTCOME NOT = 0 OR WS-FOUND = 1
         CALL "PB-RESET" USING PK-BUFFER
         CALL "TEST-NEXT-PACKET" USING PB-BUFFER PK-BUFFER WS-THRESHOLD WS-PACKET-ID WS-OUTCOME
         IF WS-OUTCOME = 0 AND WS-PACKET-ID = 49
             CALL "PB-GET-VARINT" USING PK-BUFFER WS-A
             CALL "PB-GET-VARINT" USING PK-BUFFER WS-B
             IF WS-A = 0 AND WS-B = 0
                 MOVE 1 TO WS-FOUND
             END-IF
         END-IF
     END-PERFORM
     MOVE "contract/fixtures/wire/play-s2c-31-light-update.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PK-BUFFER WS-PATH TESTLIB-ASSERT

     MOVE "acceptance US4-5 given a non-block item held (pry_bar) when place is used on a "
         & "glowtube then it toggles and nothing is placed (standin §1.3)" TO TL-CASE
     MOVE 10 TO PL-SLOT-ITEM(CN-PLAYER(WS-CONN), 1)
     MOVE 1 TO PL-SLOT-COUNT(CN-PLAYER(WS-CONN), 1)
     PERFORM USE-ON
     CALL "TEST-DRAIN-BLOCKS" USING WS-CONN WS-TEXT
     MOVE SPACES TO WS-TEXT
     PERFORM ADD-STATE
     MOVE 7 TO WS-Z
     PERFORM ADD-STATE
     MOVE 8 TO WS-Z
     MOVE "state 13 state 0" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

*> Block light of the cell above the glowtube (cell index y * 256 + z * 16 + x + 1, packed nibbles).
 ABOVE-LIGHT.
     COMPUTE WS-CELLN = 60 * 256 + 8 * 16 + 8 + 1
     COMPUTE WS-BYTE = 2048 + (WS-CELLN - 1) / 2 + 1
     IF FUNCTION MOD(WS-CELLN, 2) = 1
         COMPUTE WS-NUM = FUNCTION MOD(CE-BLOCK-LIGHT(WS-BYTE), 16)
     ELSE
         COMPUTE WS-NUM = CE-BLOCK-LIGHT(WS-BYTE) / 16
     END-IF.

*> Use Item On the glowtube's north face (the cell north of it is void) with the next sequence.
 USE-ON.
     ADD 1 TO WS-SEQ
     CALL "TEST-USE-ON" USING WS-CONN WS-X WS-Y WS-Z WS-FACE WS-SEQ.

 ADD-STATE.
     CALL "TEST-BLOCK-AT" USING WS-X WS-Y WS-Z WS-STATE
     MOVE WS-STATE TO WS-EDIT
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-TEXT) " state " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE
         INTO TL-OBSERVED
     MOVE FUNCTION TRIM(TL-OBSERVED) TO WS-TEXT.

 CHECK.
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US4-GLOWTUBE.

 COPY CORETEST.
