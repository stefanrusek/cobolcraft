*> Acceptance test of US6-1, the client half (client-surface §3 "Chat / command: T"; 08 §10.8.6
*> cobolcraft.screen.chat.hint; docs/protocol/09-cobolcraft-profile.md §1 chat is unsigned, §3.2
*> Chat 0x09): on the world screen T opens chat (the T key's own character is not typed); typed
*> characters (text events, any keyboard layout, so non-ASCII letters too) build the line, shown in
*> the input field; Enter sends Chat with the line (UTF-8; salt 0, no signature, empty last-seen
*> update) and closes chat, back to the world.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US6-CHAT-SEND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-TEXT                PIC X(1024).
 01 WS-KEY                 BINARY-LONG.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-FIVE                BINARY-LONG VALUE 5.
 01 WS-E                   PIC Z9.
 01 WS-EVENTS.
    05 WS-EVENT OCCURS 5 TIMES.
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

*>   T down, its character, T up: one frame, as the window system delivers them.
     INITIALIZE WS-EVENTS
     MOVE CC-EV-KEY-DOWN TO WS-KIND(1)
     MOVE CC-KEY-T TO WS-A(1) WS-A(3)
     MOVE CC-EV-TEXT TO WS-KIND(2)
     MOVE 116 TO WS-A(2)
     MOVE CC-EV-KEY-UP TO WS-KIND(3)
     CALL "TEST-EVENTS" USING CLIENT-STATE WS-EVENTS WS-THREE
     MOVE "acceptance US6-1 client half: given the world screen when T is pressed then chat opens "
         & "with an empty line showing the hint (the T itself is not typed)" TO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-TEXT
     MOVE SPACES TO TL-OBSERVED
     MOVE SM-SCREEN TO WS-E
     STRING FUNCTION TRIM(WS-E) " " WS-TEXT DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE SPACES TO TL-EXPECTED
     MOVE SCR-CHAT TO WS-E
     STRING FUNCTION TRIM(WS-E) " Type a message, or / for a command" DELIMITED BY SIZE
         INTO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   "hi é!" as five text events (é is code point 233).
     INITIALIZE WS-EVENTS
     MOVE CC-EV-TEXT TO WS-KIND(1) WS-KIND(2) WS-KIND(3) WS-KIND(4) WS-KIND(5)
     MOVE 104 TO WS-A(1)
     MOVE 105 TO WS-A(2)
     MOVE 32 TO WS-A(3)
     MOVE 233 TO WS-A(4)
     MOVE 33 TO WS-A(5)
     CALL "TEST-EVENTS" USING CLIENT-STATE WS-EVENTS WS-FIVE
     MOVE "acceptance US6-1 client half: when characters are typed (kind 3 events, including the "
         & "non-ASCII letter e-acute) then the line holds them as UTF-8" TO TL-CASE
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-TEXT
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE SPACES TO TL-EXPECTED
     STRING "hi " FUNCTION CHAR(196) FUNCTION CHAR(170) "!" DELIMITED BY SIZE INTO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE CC-KEY-ENTER TO WS-KEY
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE "acceptance US6-1 client half: when Enter is pressed then Chat is sent with the line "
         & "(hi e-acute !, 6 bytes), salt 0, no signature, an empty last-seen update" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING WS-TEXT(1:16) " " WS-TEXT(33:28) " " WS-TEXT(61:1) "|" DELIMITED BY SIZE
         INTO TL-OBSERVED
     MOVE "0906686920c3a921 0000000000000000000000000000  |" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US6-1 client half: when the line is sent then chat closes, back to the world"
         TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE SCR-WORLD TO TL-EXPECTED-N
     MOVE SM-SCREEN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-US6-CHAT-SEND.
 COPY CLTEST.
