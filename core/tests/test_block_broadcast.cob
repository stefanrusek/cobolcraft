*> Implementation test of the block change broadcast (core/src/blocks.cob BLOCK-CHANGE, VIEWERS-SEND;
*> tasks T450; US4-7 server half, US4 edge "two players change the same block at about the same
*> moment"): two creative players in the same dimension within view distance both receive each
*> change; a third outside the view distance (view distance 2) does not; two changes to one block in
*> one tick leave both players with the final state.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BLOCK-BROADCAST.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-BOB                 BINARY-LONG.
 01 WS-CAROL               BINARY-LONG.
 01 WS-X                   BINARY-LONG VALUE 20.
 01 WS-Y                   BINARY-LONG VALUE 99.
 01 WS-Z                   BINARY-LONG VALUE 20.
 01 WS-FACE                BINARY-LONG VALUE 1.
 01 WS-SEQ                 BINARY-LONG VALUE 0.
 01 WS-ACTION              BINARY-LONG VALUE 0.
 01 WS-STATE               BINARY-LONG.
 01 WS-MOVE                BINARY-LONG VALUE 30.
 01 WS-FX                  FLOAT-LONG VALUE 100.5.
 01 WS-FY                  FLOAT-LONG VALUE 100.0.
 01 WS-FZ                  FLOAT-LONG VALUE 100.5.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-PITCH               FLOAT-SHORT VALUE 0.
 01 WS-FLAGS               BINARY-LONG VALUE 0.
 01 WS-TEXT                PIC X(1024).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Alice" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE "Bobby" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-BOB
     MOVE "Carol" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CAROL
     CALL "TEST-MOVE" USING WS-CAROL WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     CALL "TEST-DRAIN-BLOCKS" USING WS-ALICE WS-TEXT
     CALL "TEST-DRAIN-BLOCKS" USING WS-BOB WS-TEXT
     CALL "TEST-DRAIN-BLOCKS" USING WS-CAROL WS-TEXT
     MOVE 2 TO PL-SLOT-ITEM(CN-PLAYER(WS-ALICE), 1)
     MOVE 64 TO PL-SLOT-COUNT(CN-PLAYER(WS-ALICE), 1)

     MOVE "test block broadcast a block placed by one player reaches another player in the "
         & "same dimension within view distance (Block Update and Light Update)" TO TL-CASE
     PERFORM ALICE-PLACES
     CALL "TEST-DRAIN-BLOCKS" USING WS-BOB WS-TEXT
     MOVE "49(1,1) 8(20,100,20=2)" TO TL-EXPECTED
     PERFORM CHECK
     MOVE "test block broadcast the placing player gets the same change and its Block Changed "
         & "Ack" TO TL-CASE
     CALL "TEST-DRAIN-BLOCKS" USING WS-ALICE WS-TEXT
     MOVE "49(1,1) 8(20,100,20=2) 4(1)" TO TL-EXPECTED
     PERFORM CHECK
     MOVE "test block broadcast a player outside the view distance receives nothing" TO TL-CASE
     CALL "TEST-DRAIN-BLOCKS" USING WS-CAROL WS-TEXT
     MOVE SPACES TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test block broadcast a break by the other player reaches the first" TO TL-CASE
     MOVE 100 TO WS-Y
     PERFORM BOB-BREAKS
     CALL "TEST-DRAIN-BLOCKS" USING WS-ALICE WS-TEXT
     MOVE "49(1,1) 8(20,100,20=0)" TO TL-EXPECTED
     PERFORM CHECK
     CALL "TEST-DRAIN-BLOCKS" USING WS-BOB WS-TEXT

     MOVE "test block broadcast two changes to one block in one tick (place, then break) leave "
         & "both players with the final state: each is sent both changes in arrival order"
         TO TL-CASE
     MOVE 99 TO WS-Y
     PERFORM ALICE-PLACES
     MOVE 100 TO WS-Y
     PERFORM BOB-BREAKS
     CALL "TEST-DRAIN-BLOCKS" USING WS-ALICE WS-TEXT
     MOVE "49(1,1) 8(20,100,20=2) 4(2) 49(1,1) 8(20,100,20=0)" TO TL-EXPECTED
     PERFORM CHECK
     CALL "TEST-DRAIN-BLOCKS" USING WS-BOB WS-TEXT
     MOVE "49(1,1) 8(20,100,20=2) 49(1,1) 8(20,100,20=0) 4(2)" TO TL-EXPECTED
     PERFORM CHECK
     CALL "TEST-BLOCK-AT" USING WS-X WS-Y WS-Z WS-STATE
     MOVE "test block broadcast the server's block is the final state (void)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-STATE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 ALICE-PLACES.
     ADD 1 TO WS-SEQ
     CALL "TEST-USE-ON" USING WS-ALICE WS-X WS-Y WS-Z WS-FACE WS-SEQ.

 BOB-BREAKS.
     CALL "TEST-ACTION" USING WS-BOB WS-ACTION WS-X WS-Y WS-Z WS-FACE WS-SEQ.

 CHECK.
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-BLOCK-BROADCAST.

 COPY CORETEST.
