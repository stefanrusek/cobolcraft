*> Acceptance test of US14-1, the client half (client-surface §3 "Chat / command: `/` opens chat
*> with `/` typed"; docs/protocol/09-cobolcraft-profile.md §3.3 Commands, Command Suggestion(s),
*> §5 rule 5): on the world screen `/` opens chat with `/` already on the line; the command names
*> of the received tree (Commands, play-s2c-10-commands-everyone.hex, the level 0 tree of 57-client-closures-4 section 10.1: me, help, list, msg, tell, w, random, teammsg, tm,
*> trigger) that start with the word being typed are suggested; at an argument with ask_server suggestions
*> (/trigger ob) the client sends Command Suggestion with the line and shows the answers of the
*> Command Suggestions that come back.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US14-SUGGESTIONS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-PATH                PIC X(256).
 01 WS-TEXT                PIC X(1024).
 01 WS-SCREEN-TEXT         PIC X(1024).
 01 WS-TYPED               PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-E                   PIC Z9.
 01 WS-EVENTS.
    05 WS-EVENT OCCURS 3 TIMES.
       10 WS-KIND          BINARY-LONG.
       10 WS-A             BINARY-LONG.
       10 WS-B             BINARY-LONG.
       10 WS-C             BINARY-LONG.
       10 WS-X             FLOAT-SHORT.
       10 WS-Y             FLOAT-SHORT.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE "contract/fixtures/wire/play-s2c-10-commands-everyone.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH

*>   / down, its character, / up: one frame, as the window system delivers them.
     INITIALIZE WS-EVENTS
     MOVE CC-EV-KEY-DOWN TO WS-KIND(1)
     MOVE CC-KEY-SLASH TO WS-A(1) WS-A(3)
     MOVE CC-EV-TEXT TO WS-KIND(2)
     MOVE 47 TO WS-A(2)
     MOVE CC-EV-KEY-UP TO WS-KIND(3)
     CALL "TEST-EVENTS" USING CLIENT-STATE WS-EVENTS WS-THREE
     MOVE "acceptance US14-1 client half: given the world screen and the received command tree "
         & "when / is pressed then chat opens with / typed (once) and the commands the Player "
         & "may use are suggested" TO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-SCREEN-TEXT
     MOVE SPACES TO TL-OBSERVED
     MOVE SM-SCREEN TO WS-E
     STRING FUNCTION TRIM(WS-E) " " WS-SCREEN-TEXT DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE SPACES TO TL-EXPECTED
     MOVE SCR-CHAT TO WS-E
     STRING FUNCTION TRIM(WS-E) " /|help|list|me|msg|random|teammsg|tell|tm|trigger|w" DELIMITED BY SIZE INTO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "t" TO WS-TYPED
     MOVE 1 TO WS-LENGTH
     CALL "TEST-TYPE" USING CLIENT-STATE WS-TYPED WS-LENGTH
     MOVE "acceptance US14-1 client half: when t is typed then only teammsg, tell, tm and trigger, the command names "
         & "matching the typed prefix, are suggested" TO TL-CASE
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-SCREEN-TEXT
     MOVE WS-SCREEN-TEXT TO TL-OBSERVED
     MOVE "/t|teammsg|tell|tm|trigger" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "rigger ob" TO WS-TYPED
     MOVE 9 TO WS-LENGTH
     CALL "TEST-TYPE" USING CLIENT-STATE WS-TYPED WS-LENGTH
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE "acceptance US14-1 client half: when the line reaches the objective argument of trigger "
         & "(ask_server suggestions) then Command Suggestion is sent with transaction 1 and the "
         & "line /trigger ob" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "0f010b2f74726967676572206f62" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "contract/fixtures/wire/play-s2c-0f-command-suggestions.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE "acceptance US14-1 client half: when Command Suggestions answers transaction 1 then "
         & "its suggestion Alice is shown" TO TL-CASE
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-SCREEN-TEXT
     MOVE WS-SCREEN-TEXT TO TL-OBSERVED
     MOVE "/trigger ob|Alice" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE "acceptance US14-1 client half: while the line stays the same the server is not asked "
         & "again" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE SPACES TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-US14-SUGGESTIONS.
 COPY CLTEST.
