*> Acceptance test of US14 command sending, the client half (client-surface §3 "Chat / command";
*> docs/protocol/09-cobolcraft-profile.md §1 chat is unsigned, §3.3 Chat Command 0x07, System Chat
*> command feedback): Enter on a line starting with `/` sends Chat Command with the line without
*> its `/` (play-c2s-07-chat-command.hex), not Chat, and closes chat; the System Chat reply
*> (play-s2c-7c-system-chat-command-feedback.hex) appears in the chat area.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US14-COMMAND-SEND.
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
 01 WS-KEY                 BINARY-LONG.
 01 WS-E                   PIC Z9.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD

     MOVE CC-KEY-SLASH TO WS-KEY
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     MOVE "promote Alice" TO WS-TYPED
     MOVE 13 TO WS-LENGTH
     CALL "TEST-TYPE" USING CLIENT-STATE WS-TYPED WS-LENGTH
     MOVE CC-KEY-ENTER TO WS-KEY
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE "acceptance US14-2 client half: given chat open with /promote Alice when Enter is "
         & "pressed then Chat Command is sent with promote Alice (no slash, not Chat) and chat "
         & "closes" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     MOVE SM-SCREEN TO WS-E
     STRING FUNCTION TRIM(WS-TEXT) " " FUNCTION TRIM(WS-E) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE SPACES TO TL-EXPECTED
     MOVE SCR-WORLD TO WS-E
     STRING "070d70726f6d6f746520416c696365 " FUNCTION TRIM(WS-E) DELIMITED BY SIZE
         INTO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "contract/fixtures/wire/play-s2c-7c-system-chat-command-feedback.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE "acceptance US14-2 client half: when the System Chat reply arrives then it appears in "
         & "the chat area, rendered through the language" TO TL-CASE
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-SCREEN-TEXT
     MOVE 0 TO WS-LENGTH
     INSPECT WS-SCREEN-TEXT TALLYING WS-LENGTH FOR ALL "Alice now holds operator status"
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-LENGTH TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE CC-KEY-T TO WS-KEY
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     MOVE "hi" TO WS-TYPED
     MOVE 2 TO WS-LENGTH
     CALL "TEST-TYPE" USING CLIENT-STATE WS-TYPED WS-LENGTH
     MOVE CC-KEY-ENTER TO WS-KEY
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE "acceptance US14-2 client half: a line without a leading / is still sent as Chat"
         TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT(1:8) TO TL-OBSERVED
     MOVE "09026869" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-US14-COMMAND-SEND.
 COPY CLTEST.
