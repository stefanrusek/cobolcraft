*> Test of the server side of tab completion (docs/protocol/54-client-gap-closures.md §14): each player has one slot for the latest unprocessed Command Suggestion request,
*> a newer request replaces an older one that was not yet answered (no answer for it), at most one request per player is answered per tick (CMD-SUGGEST-FLUSH,
*> called by CORE-TICK), the ranges count the slash, the entries are capped at 1000, and the Commands tree (0x10) is sent again after a respawn as well as on joining and
*> on a permission change. Opal holds operator status.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-SUGGEST-SLOT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 01 WS-ID-OPAL             BINARY-LONG.
 01 WS-ID-ALICE            BINARY-LONG.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-LINE                PIC X(768).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-TEXT                PIC X(4096).
 01 WS-DISCARD             PIC X(4096).
 01 WS-EXPECTED            PIC X(1024).
 01 WS-FOUND               BINARY-LONG.
 01 WS-PACKET-ID           BINARY-LONG VALUE 16.
 01 WS-ACTION              BINARY-LONG VALUE 0.
 01 WS-TRANSACTION         BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-COUNT               BINARY-LONG.
 01 WS-RESULT              PIC X(32).
 01 WS-EDIT                PIC Z(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Opal" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-ID-OPAL
     MOVE "Alice" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID-ALICE
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-DISCARD

     MOVE "acceptance US14 suggestions: the range counts the slash (/gamemode s: start 10, length 1) and the id is echoed (54 s14.1)" TO TL-CASE
     MOVE "/gamemode s" TO WS-LINE
     MOVE 7 TO WS-TRANSACTION
     MOVE 11 TO WS-LENGTH
     CALL "TEST-SUGGEST" USING WS-ID-OPAL WS-TRANSACTION WS-LINE WS-LENGTH
     CALL "TEST-DRAIN-SUGGESTIONS" USING WS-ID-OPAL WS-TEXT
     MOVE "7 10 1 [spectator,survival]" TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT

     MOVE "acceptance US14 suggestions: two requests in one tick: only the newest is answered, the older id is never echoed (54 s14.1)" TO TL-CASE
     MOVE "/g" TO WS-LINE
     MOVE 1 TO WS-TRANSACTION
     MOVE 2 TO WS-LENGTH
     CALL "TEST-SUGGEST" USING WS-ID-OPAL WS-TRANSACTION WS-LINE WS-LENGTH
     MOVE "/gam" TO WS-LINE
     MOVE 2 TO WS-TRANSACTION
     MOVE 4 TO WS-LENGTH
     CALL "TEST-SUGGEST" USING WS-ID-OPAL WS-TRANSACTION WS-LINE WS-LENGTH
     CALL "TEST-DRAIN-SUGGESTIONS" USING WS-ID-OPAL WS-TEXT
     MOVE "2 1 3 [gamemode,gamerule]" TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT

     MOVE "acceptance US14 suggestions: the slot is empty after the answer, a second tick answers nothing (one answer per tick)" TO TL-CASE
     CALL "CMD-SUGGEST-FLUSH"
     CALL "TEST-DRAIN-SUGGESTIONS" USING WS-ID-OPAL WS-TEXT
     MOVE SPACES TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT

     MOVE "acceptance US14 suggestions: the slots are per player: both players are answered in one tick" TO TL-CASE
     MOVE "/gam" TO WS-LINE
     MOVE 3 TO WS-TRANSACTION
     MOVE 4 TO WS-LENGTH
     CALL "TEST-SUGGEST" USING WS-ID-OPAL WS-TRANSACTION WS-LINE WS-LENGTH
     MOVE 4 TO WS-TRANSACTION
     CALL "TEST-SUGGEST" USING WS-ID-ALICE WS-TRANSACTION WS-LINE WS-LENGTH
     CALL "CMD-SUGGEST-FLUSH"
     CALL "TEST-DRAIN-SUGGESTIONS" USING WS-ID-OPAL WS-TEXT
     MOVE "3 1 3 [gamemode,gamerule]" TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US14 suggestions: Alice's own request in the same tick is answered with her own id (15a 6.1: the root offers every literal)" TO TL-CASE
     CALL "TEST-DRAIN-SUGGESTIONS" USING WS-ID-ALICE WS-TEXT
     MOVE "4 1 3 [gamemode,gamerule]" TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT

     MOVE "acceptance US14 suggestions: a list of 1500 entries is cut to the first 1000, a short list is kept (54 s14.1)" TO TL-CASE
     MOVE 1500 TO WS-COUNT
     CALL "CMD-SUGGEST-CAP" USING WS-COUNT
     MOVE WS-COUNT TO WS-EDIT
     MOVE SPACES TO WS-RESULT
     MOVE FUNCTION TRIM(WS-EDIT) TO WS-RESULT(1:4)
     MOVE 5 TO WS-COUNT
     CALL "CMD-SUGGEST-CAP" USING WS-COUNT
     MOVE WS-COUNT TO WS-EDIT
     MOVE FUNCTION TRIM(WS-EDIT) TO WS-RESULT(6:1)
     MOVE "1000 5" TO WS-EXPECTED
     MOVE FUNCTION CONCATENATE(WS-RESULT(1:4) " " WS-RESULT(6:1)) TO WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT

     MOVE "acceptance US14 commands tree: a respawn sends the Commands packet again (54 s14.2)" TO TL-CASE
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-DISCARD
     MOVE "kill Alice" TO WS-LINE
     CALL "TEST-COMMAND" USING WS-ID-OPAL WS-LINE
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-DISCARD
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-CLIENT-COMMAND" USING WS-ID-ALICE WS-ACTION
     CALL "TEST-DRAIN-PACKET" USING WS-ID-ALICE WS-PACKET-ID PB-BUFFER WS-FOUND
     CALL "PB-FREE" USING PB-BUFFER
     MOVE WS-FOUND TO WS-EDIT
     MOVE "1" TO WS-EXPECTED
     MOVE FUNCTION TRIM(WS-EDIT) TO WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     GOBACK.
 END PROGRAM TEST-CMD-SUGGEST-SLOT.

 COPY CORETEST.
 COPY CMDTEST.
