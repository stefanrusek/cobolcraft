*> Test of the tooltips of command suggestions (docs/protocol/57-client-closures-4 section 8.3): of the nodes a server answers (ask_server) only the score_holder nodes give tooltips: the six
*> selector heads, in the answer sorted with the names, each with its translatable component (argument.entity.selector.nearestPlayer for @p and so on) when the source holds the selector
*> atom (level 2); the player names carry none. The entity nodes keep their heads without tooltips (the client suggests for them itself, 8.4), a level 0 source gets names only.
*> Opal holds operator status; Alice does not.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-SUGGEST-TOOLTIP.
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
 01 WS-SUGGESTION-ID       BINARY-LONG VALUE 1.
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
     MOVE "T" TO TL-MODE

     MOVE "/scoreboard players add " TO WS-LINE
     MOVE 24 TO WS-LENGTH
     CALL "TEST-SUGGEST" USING WS-ID-OPAL WS-SUGGESTION-ID WS-LINE WS-LENGTH
     CALL "TEST-DRAIN-SUGGESTIONS" USING WS-ID-OPAL WS-TEXT
     MOVE "test cmd suggest tooltip a score holder offers the six heads with their tooltips and the names without" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE SPACES TO TL-EXPECTED
     STRING "1 24 0 [@a(tooltip:argument.entity.selector.allPlayers),@e(tooltip:argument.entity.selector.allEntities),"
         "@n(tooltip:argument.entity.selector.nearestEntity),@p(tooltip:argument.entity.selector.nearestPlayer),"
         "@r(tooltip:argument.entity.selector.randomPlayer),@s(tooltip:argument.entity.selector.self),Alice,Opal]"
         DELIMITED BY SIZE INTO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "/tellraw " TO WS-LINE
     MOVE 9 TO WS-LENGTH
     CALL "TEST-SUGGEST" USING WS-ID-OPAL WS-SUGGESTION-ID WS-LINE WS-LENGTH
     CALL "TEST-DRAIN-SUGGESTIONS" USING WS-ID-OPAL WS-TEXT
     MOVE "test cmd suggest tooltip an entity node offers its heads without tooltips" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "1 9 0 [@a,@e,@n,@p,@r,@s,Alice,Opal]" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "/msg " TO WS-LINE
     MOVE 5 TO WS-LENGTH
     CALL "TEST-SUGGEST" USING WS-ID-ALICE WS-SUGGESTION-ID WS-LINE WS-LENGTH
     CALL "TEST-DRAIN-SUGGESTIONS" USING WS-ID-ALICE WS-TEXT
     MOVE "test cmd suggest tooltip a level 0 source gets the names only" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "1 5 0 [Alice,Opal]" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-CMD-SUGGEST-TOOLTIP.

 COPY CORETEST.
 COPY CMDTEST.
