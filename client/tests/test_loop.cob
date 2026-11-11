*> Implementation test of client/src/loop.cob (CL-START, CL-STEP; research R6): CL-STEP routes the
*> frame's events (a close request ends the run), pumps the game connection without waiting (a
*> Keep Alive the server sends is echoed within the frame, after the frame's tick), sends Client
*> Tick End once per 50 ms client tick in play, re-meshes the replica's changed sections, and
*> produces the screen model and the render list every frame.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-LOOP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY PROTO.
 COPY TESTLIB.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-SERVER              BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-PATH                PIC X(256).
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-ID                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 01 WS-S                   BINARY-LONG.
 01 WS-DIRTY               BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-EVENTS.
    05 WS-KIND             BINARY-LONG.
    05 FILLER              PIC X(20) VALUE LOW-VALUES.
 PROCEDURE DIVISION.
     CALL "SYSTEM" USING "rm -rf build/client-test-loop"
     CALL "CL-INIT" USING CLIENT-STATE
     MOVE "Alice" TO CL-NAME
     MOVE 5 TO CL-NAME-LENGTH
     MOVE "build/client-test-loop" TO CL-GAME-DIR
     MOVE 22 TO CL-GAME-DIR-LENGTH
     CALL "CL-START" USING CLIENT-STATE
     CALL "NET-BUFFERS-INIT" USING CLIENT-STATE WS-CONN
     CALL "TEST-LOOPBACK" USING CLIENT-STATE WS-CONN WS-SERVER
     MOVE PH-PLAY TO CN-PHASE(WS-CONN)
     MOVE SCR-WORLD TO SM-SCREEN
     MOVE 256 TO PL-HEIGHT
     MOVE 3 TO RG-BIOMES
     MOVE 4.5 TO PL-X
     MOVE 54 TO PL-Y
     MOVE 8.5 TO PL-Z
     MOVE "contract/fixtures/wire/play-s2c-2e-level-chunk-with-light-spawn.hex" TO WS-PATH
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-LOAD-HEX" USING WS-PATH PB-BUFFER
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-ID
     CALL "REPLICA-CHUNK-LOAD" USING CLIENT-STATE PB-BUFFER
     PERFORM 3 TIMES
         CALL "TEST-STEP" USING CLIENT-STATE
     END-PERFORM
     CALL "WORLD-ROW" USING CLIENT-STATE WS-ZERO WS-ZERO2 WS-ROW
     MOVE 0 TO WS-DIRTY
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 16
         ADD WR-DIRTY(WS-ROW, WS-S) TO WS-DIRTY
     END-PERFORM
     MOVE "loop the changed sections of a received chunk are meshed by the following frames"
         TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-DIRTY TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "loop every frame produces the screen model (the HUD crosshair, a sprite widget of kind 8) and a render list whose "
         & "last draw is the UI" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "8 2" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION CHAR(SM-W-KIND(1) + 49) " " FUNCTION CHAR(RL-D-PIPELINE(RL-DRAW-COUNT) + 49)
         DELIMITED BY SIZE INTO TL-OBSERVED
     IF RL-DRAW-COUNT < 2
         MOVE "no world draws" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "TEST-SERVER-READ" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE "loop Client Tick End is sent once per 50 ms tick (three frames of 20 ms: one tick)"
         TO TL-CASE
     MOVE "0d" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "contract/fixtures/wire/play-s2c-2d-keep-alive.hex" TO WS-PATH
     CALL "TEST-SERVE" USING WS-SERVER WS-PATH WS-THRESHOLD
     CALL "TEST-SLEEP"
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-SERVER-READ" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE "loop the connection is pumped every frame after the tick: a Keep Alive is echoed in "
         & "the same frame, after that frame's Client Tick End" TO TL-CASE
     MOVE "0d 1c" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE CC-EV-CLOSE-REQUEST TO WS-KIND
     CALL "TEST-EVENTS" USING CLIENT-STATE WS-EVENTS WS-ONE
     MOVE "loop a close request ends the run" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE CL-QUIT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-LOOP.
 COPY CLTEST.
