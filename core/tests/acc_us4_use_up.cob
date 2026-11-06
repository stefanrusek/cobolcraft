*> Acceptance test, US4 edge case "in survival a placed block uses up one item from the held stack; in
*> creative it does not" (tasks T435; FR-007; 09 §3.2 Container Set Slot row). Alice (survival, the
*> starting greystone in slot 0) and Bob (creative, 64 greystone put in slot 0) each place a block.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US4-USE-UP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-BOB                 BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-X                   BINARY-LONG VALUE 10.
 01 WS-Y                   BINARY-LONG VALUE 99.
 01 WS-Z                   BINARY-LONG VALUE 10.
 01 WS-FACE                BINARY-LONG VALUE 1.
 01 WS-SEQ                 BINARY-LONG VALUE 1.
 01 WS-CLOSE               BINARY-LONG.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-PATH                PIC X(256).
 01 WS-TEXT                PIC X(1024).
 01 WS-EDIT                PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-DEFAULT-MODE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-INIT" USING PK-BUFFER WS-CAPACITY
     MOVE "Alice" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE

     MOVE "acceptance US4 edge given survival when a block is placed then one item leaves the "
         & "held stack (64 to 63)" TO TL-CASE
     CALL "TEST-USE-ON" USING WS-ALICE WS-X WS-Y WS-Z WS-FACE WS-SEQ
     MOVE "N" TO TL-MODE
     MOVE 63 TO TL-EXPECTED-N
     MOVE PL-SLOT-COUNT(CN-PLAYER(WS-ALICE), 1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US4 edge given survival when a block is placed then the player is sent "
         & "Container Set Slot of the held slot equal to play-s2c-14-container-set-slot.hex "
         & "(state id 2, slot 0, 63 greystone)" TO TL-CASE
     CALL "TEST-DRAIN" USING WS-ALICE PB-BUFFER WS-CLOSE
     MOVE 0 TO WS-OUTCOME WS-FOUND
     PERFORM UNTIL WS-OUTCOME NOT = 0 OR WS-FOUND = 1
         CALL "PB-RESET" USING PK-BUFFER
         CALL "TEST-NEXT-PACKET" USING PB-BUFFER PK-BUFFER WS-THRESHOLD WS-PACKET-ID WS-OUTCOME
         IF WS-OUTCOME = 0 AND WS-PACKET-ID = 20
             MOVE 1 TO WS-FOUND
         END-IF
     END-PERFORM
     MOVE "contract/fixtures/wire/play-s2c-14-container-set-slot.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PK-BUFFER WS-PATH TESTLIB-ASSERT

     MOVE 1 TO CS-DEFAULT-MODE
     MOVE CORE-SETTINGS TO CW-SETTINGS
     MOVE "Bobby" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-BOB
     MOVE CN-PLAYER(WS-BOB) TO WS-ROW
     MOVE 2 TO PL-SLOT-ITEM(WS-ROW, 1)
     MOVE 64 TO PL-SLOT-COUNT(WS-ROW, 1)
     MOVE 12 TO WS-X
     ADD 1 TO WS-SEQ
     CALL "TEST-USE-ON" USING WS-BOB WS-X WS-Y WS-Z WS-FACE WS-SEQ
     CALL "TEST-DRAIN-BLOCKS" USING WS-BOB WS-TEXT
     MOVE "acceptance US4 edge given creative when a block is placed then the stack is unchanged "
         & "(64) and no Container Set Slot is sent" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "8(12,100,10=2) 49(0,0) 4(2) 64" TO TL-EXPECTED
     MOVE PL-SLOT-COUNT(WS-ROW, 1) TO WS-EDIT
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-TEXT) " " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE
         INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-US4-USE-UP.

 COPY CORETEST.
