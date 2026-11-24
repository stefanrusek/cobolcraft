*> Implementation test of the Block Changed Ack a connection owes when it ends (core/src/session.cob SESSION-RELEASE, lane bugrejoin,
*> operator report of try13: leaving a single-player world through the pause menu and opening a world again ended in "No reply arrived
*> in time"). BC-ACK is kept per connection id; a connection that ended with an acknowledgement still owed (a Player Action of its last
*> frame, no tick since) left it in the table, the next connection of the same id got it as a Block Changed Ack at its first tick
*> (an unexpected packet for its client: answered as a Keep Alive, then disconnect.timeout). Releasing a connection drops what it owed;
*> the client side is test_rejoin.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ACK-LEAVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY BCHANGE.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-SEQ                 BINARY-LONG VALUE 7.
 01 WS-RESULT              BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE "T" TO TL-MODE
     CALL "BC-ACK-SET" USING WS-ALICE WS-SEQ WS-RESULT
     CALL "CORE-CONN-CLOSED" USING WS-ALICE
     MOVE "ack owed by a connection that ends is dropped with it (BC-ACK of its id)" TO TL-CASE
     MOVE "owed 0" TO TL-EXPECTED
     MOVE BC-ACK(WS-ALICE) TO WS-E1
     MOVE SPACES TO TL-OBSERVED
     STRING "owed " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     STOP RUN.
 END PROGRAM TEST-ACK-LEAVE.

 COPY CORETEST.
