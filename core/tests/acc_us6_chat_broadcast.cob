*> Acceptance test, US6-1 core half (spec US6 scenario 1; FR-013; SC-006 server half; tasks T480;
*> docs/protocol/09-cobolcraft-profile.md §1 "Chat is unsigned", §3.2 rows 0x09 and 0x7C): a Chat
*> message from one player reaches every connected player, the sender included and whatever their
*> dimension, as System Chat with the literal text `<name> message`, and all players see the
*> messages in the order the server received them. Alice, Bobby and Carol join; Bobby is then put in
*> the second dimension row (travel between dimensions is US12), so the players are in different
*> dimensions.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US6-CHAT-BROADCAST.
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
 01 WS-MESSAGE             PIC X(768).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-TEXT                PIC X(4096).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Alice" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE "Bobby" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-BOB
     MOVE "Carol" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CAROL
     MOVE 2 TO PL-DIM(CN-PLAYER(WS-BOB))
     CALL "TEST-DRAIN-CHAT" USING WS-ALICE WS-TEXT
     CALL "TEST-DRAIN-CHAT" USING WS-BOB WS-TEXT
     CALL "TEST-DRAIN-CHAT" USING WS-CAROL WS-TEXT

     MOVE "hello" TO WS-MESSAGE
     MOVE 5 TO WS-LENGTH
     CALL "TEST-CHAT" USING WS-ALICE WS-MESSAGE WS-LENGTH

     MOVE "acceptance US6-1 given players in different dimensions when Alice sends a message then "
         & "she, the sender, receives <Alice> hello as System Chat" TO TL-CASE
     CALL "TEST-DRAIN-CHAT" USING WS-ALICE WS-TEXT
     MOVE "<Alice> hello" TO TL-EXPECTED
     PERFORM CHECK
     MOVE "acceptance US6-1 given players in different dimensions when Alice sends a message then "
         & "Bobby, in the other dimension, receives <Alice> hello as System Chat" TO TL-CASE
     CALL "TEST-DRAIN-CHAT" USING WS-BOB WS-TEXT
     PERFORM CHECK
     MOVE "acceptance US6-1 given players in different dimensions when Alice sends a message then "
         & "Carol, in her dimension, receives <Alice> hello as System Chat" TO TL-CASE
     CALL "TEST-DRAIN-CHAT" USING WS-CAROL WS-TEXT
     PERFORM CHECK

     MOVE "how are you" TO WS-MESSAGE
     MOVE 11 TO WS-LENGTH
     CALL "TEST-CHAT" USING WS-BOB WS-MESSAGE WS-LENGTH
     MOVE "fine" TO WS-MESSAGE
     MOVE 4 TO WS-LENGTH
     CALL "TEST-CHAT" USING WS-CAROL WS-MESSAGE WS-LENGTH
     MOVE "great" TO WS-MESSAGE
     MOVE 5 TO WS-LENGTH
     CALL "TEST-CHAT" USING WS-ALICE WS-MESSAGE WS-LENGTH
     MOVE "<Bobby> how are you | <Carol> fine | <Alice> great" TO TL-EXPECTED
     MOVE "acceptance US6-1 given players in different dimensions when three players each send a "
         & "message then Alice receives all three in the order the server received them" TO TL-CASE
     CALL "TEST-DRAIN-CHAT" USING WS-ALICE WS-TEXT
     PERFORM CHECK
     MOVE "acceptance US6-1 given players in different dimensions when three players each send a "
         & "message then Bobby receives all three in the order the server received them" TO TL-CASE
     CALL "TEST-DRAIN-CHAT" USING WS-BOB WS-TEXT
     PERFORM CHECK
     MOVE "acceptance US6-1 given players in different dimensions when three players each send a "
         & "message then Carol receives all three in the order the server received them" TO TL-CASE
     CALL "TEST-DRAIN-CHAT" USING WS-CAROL WS-TEXT
     PERFORM CHECK
     STOP RUN.

 CHECK.
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US6-CHAT-BROADCAST.

 COPY CORETEST.
