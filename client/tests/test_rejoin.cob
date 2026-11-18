*> Implementation test of leaving a single-player world through the pause menu and opening a world again (lane bugrejoin, operator report
*> of try13: after quitting to the title screen and opening another world the client showed "No reply arrived in time", the core's
*> keep-alive timeout). The Player is breaking a block (CT-BREAKING 1) when Escape opens the pause menu: the client's frame sends a
*> Player Action (abort), the core answers it with a Block Changed Ack at its next tick, and the pause holds the ticks, so the ack was
*> still owed when Save and Leave the World ended the connection (core BC-ACK, kept per connection id). The next world's connection (the same id)
*> got that ack in its configuration phase, its client answered it as a Keep Alive and the core disconnected it (disconnect.timeout).
*> Both ways of opening again (the same folder, another folder) reach play, loaded, with no message, and stay there over 700 frames
*> (more than two keep-alive periods of the core); the control (no break in progress) did so before the fix too.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-REJOIN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 COPY CCSHIM.
 01 WS-DIR                 PIC X(64) VALUE "build/client-test-rejoin".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 24.
 01 WS-FOLDER              PIC X(80) VALUE "First".
 01 WS-FOLDER-LENGTH       BINARY-LONG VALUE 5.
 01 WS-NAME                PIC X(64) VALUE "First".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-FOLDER-B            PIC X(80) VALUE "Second".
 01 WS-LENGTH-B            BINARY-LONG VALUE 6.
 01 WS-NAME-B              PIC X(64) VALUE "Second".
 01 WS-NAME-LENGTH-B       BINARY-LONG VALUE 6.
 01 WS-MODE                BINARY-LONG VALUE 0.
 01 WS-JOINED              BINARY-LONG.
 01 WS-KEY                 BINARY-LONG VALUE CC-KEY-ESCAPE.
 01 WS-ACTION              BINARY-LONG.
 01 WS-ARG                 BINARY-LONG VALUE 0.
 01 WS-FOUND               BINARY-LONG.
 01 WS-STEPS               BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SP-START" USING CLIENT-STATE WS-DIR WS-DIR-LENGTH
     MOVE "T" TO TL-MODE
     CALL "SP-OPEN" USING CLIENT-STATE WS-FOLDER WS-FOLDER-LENGTH WS-NAME WS-NAME-LENGTH WS-MODE
     CALL "TEST-SP-JOIN" USING CLIENT-STATE WS-JOINED
     PERFORM CHECK-PLAYING
     MOVE "rejoin world A joined for the first time" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Control: Save and Leave with nothing owed, the same folder again.
     PERFORM QUIT-BY-PAUSE-MENU
     CALL "SP-OPEN" USING CLIENT-STATE WS-FOLDER WS-FOLDER-LENGTH WS-NAME WS-NAME-LENGTH WS-MODE
     PERFORM JOIN-AND-RUN
     MOVE "rejoin the same world after Save and Leave (nothing owed)" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A break in progress when Escape is pressed, the same folder again.
     PERFORM BREAK-AND-QUIT
     CALL "SP-OPEN" USING CLIENT-STATE WS-FOLDER WS-FOLDER-LENGTH WS-NAME WS-NAME-LENGTH WS-MODE
     PERFORM JOIN-AND-RUN
     MOVE "rejoin the same world after Save and Leave with a block break in progress" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A break in progress, another folder.
     PERFORM BREAK-AND-QUIT
     CALL "SP-OPEN" USING CLIENT-STATE WS-FOLDER-B WS-LENGTH-B WS-NAME-B WS-NAME-LENGTH-B WS-MODE
     PERFORM JOIN-AND-RUN
     MOVE "rejoin another world after Save and Leave with a block break in progress" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.

 JOIN-AND-RUN.
     CALL "TEST-SP-JOIN" USING CLIENT-STATE WS-JOINED
     MOVE 700 TO WS-STEPS
     CALL "TEST-TICKS" USING CLIENT-STATE WS-STEPS
     PERFORM CHECK-PLAYING
     EXIT PARAGRAPH.

*>   The break of the block under the Player's feet is in progress (the button is up in the next frame, so the controls abort it,
*>   which sends the Player Action), then Escape and Save and Leave the World.
 BREAK-AND-QUIT.
     MOVE 1 TO CT-BREAKING
     COMPUTE CT-BREAK-X = PL-X
     COMPUTE CT-BREAK-Y = PL-Y - 1
     COMPUTE CT-BREAK-Z = PL-Z
     MOVE 1 TO CT-BREAK-FACE
     PERFORM QUIT-BY-PAUSE-MENU
     EXIT PARAGRAPH.

 QUIT-BY-PAUSE-MENU.
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     MOVE ACT-QUIT-WORLD TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     EXIT PARAGRAPH.

*>   Joined, in play, no message, on the world screen.
 CHECK-PLAYING.
     MOVE "joined 1 phase 5 message 0 screen 5" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-JOINED TO WS-E1
     MOVE CN-PHASE(CONN-GAME) TO WS-E2
     MOVE SM-MESSAGE-LENGTH TO WS-E3
     STRING "joined " FUNCTION TRIM(WS-E1) " phase " FUNCTION TRIM(WS-E2) " message " FUNCTION TRIM(WS-E3)
         " screen " FUNCTION CHAR(SM-SCREEN + 49) DELIMITED BY SIZE INTO TL-OBSERVED
     EXIT PARAGRAPH.
 END PROGRAM TEST-REJOIN.
 COPY CLTEST.
