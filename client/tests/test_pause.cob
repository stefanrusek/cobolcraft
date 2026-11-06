*> Implementation test of client/src/screens/pause.cob (US2-5 client half; client-surface.md §3
*> Escape; 08 §10.8.6 pause texts): Escape in the world opens the pause menu; Escape or its resume
*> control goes back to the world; its disconnect control closes the connection and returns to the
*> server list.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PAUSE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY TESTLIB.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-SERVER              BINARY-LONG.
 01 WS-KEY                 BINARY-LONG VALUE CC-KEY-ESCAPE.
 01 WS-ACTION              BINARY-LONG.
 01 WS-ARG                 BINARY-LONG VALUE 0.
 01 WS-FOUND               BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 PROCEDURE DIVISION.
     CALL "SYSTEM" USING "rm -rf build/client-test-pause"
     CALL "CL-INIT" USING CLIENT-STATE
     MOVE "Alice" TO CL-NAME
     MOVE 5 TO CL-NAME-LENGTH
     MOVE "build/client-test-pause" TO CL-GAME-DIR
     MOVE 23 TO CL-GAME-DIR-LENGTH
     CALL "CL-START" USING CLIENT-STATE
     CALL "NET-BUFFERS-INIT" USING CLIENT-STATE WS-CONN
     CALL "TEST-LOOPBACK" USING CLIENT-STATE WS-CONN WS-SERVER
     MOVE PH-CONFIG TO CN-PHASE(WS-CONN)
     MOVE SCR-WORLD TO SM-SCREEN
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-TEXT
     MOVE "pause Escape in the world opens the pause menu (title, back to the world, disconnect)"
         TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION CHAR(SM-SCREEN + 49) " " FUNCTION TRIM(WS-TEXT) DELIMITED BY SIZE
         INTO TL-OBSERVED
     MOVE "9 Game Menu|Back to the World|Disconnect" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE ACT-RESUME TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     MOVE SM-SCREEN TO TL-OBSERVED-N
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     MOVE "pause Back to the World, or Escape in the pause menu, returns to the world" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N = SCR-WORLD * 100 + SCR-WORLD
     COMPUTE TL-OBSERVED-N = TL-OBSERVED-N * 100 + SM-SCREEN
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     MOVE ACT-DISCONNECT TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     CALL "TEST-SERVER-READ" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE "acceptance US2-5 given the Player is in the world when they press the disconnect "
         & "control then the connection is closed and they return to the server list" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "closed 0 2" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-TEXT) " " FUNCTION CHAR(CN-PHASE(WS-CONN) + 49) " "
         FUNCTION CHAR(SM-SCREEN + 49) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-PAUSE.
 COPY CLTEST.
