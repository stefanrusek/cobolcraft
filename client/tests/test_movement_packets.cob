*> Implementation test of the movement packets of client/src/protocol-client.cob (CLP-MOVE-SEND;
*> 05c 0x1E to 0x21; 09 §3.2): the client sends the Move Player variant matching what changed since
*> the server last heard (position and rotation 0x1F, position 0x1E, rotation 0x20, only the
*> MoveFlags 0x21, nothing when nothing changed); a server Player Position is applied as a
*> correction (velocity stopped) and accepted, and is not echoed back as a move; in play each
*> client tick sends its move before Client Tick End.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOVEMENT-PACKETS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY PROTO.
 COPY TESTLIB.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-INDEX               BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-PATH                PIC X(256).
 01 WS-SERVER              BINARY-LONG.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-TEXT                PIC X(1024).
 01 WS-KEY                 BINARY-LONG VALUE CC-KEY-W.
 01 WS-DOWN                BINARY-LONG VALUE CC-EV-KEY-DOWN.
 01 WS-UP                  BINARY-LONG VALUE CC-EV-KEY-UP.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-MS                  BINARY-LONG VALUE 50.
 01 WS-EVENT.
    05 WS-KIND             BINARY-LONG.
    05 FILLER              PIC X(12).
    05 WS-DX               FLOAT-SHORT.
    05 WS-DY               FLOAT-SHORT.
 PROCEDURE DIVISION.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "NET-BUFFERS-INIT" USING CLIENT-STATE WS-CONN
     MOVE PH-PLAY TO CN-PHASE(WS-CONN)
     MOVE 5.25 TO PL-X
     MOVE 54 TO PL-Y PL-SENT-Y
     MOVE 8.5 TO PL-Z PL-SENT-Z
     MOVE 4.5 TO PL-SENT-X
     MOVE 1 TO PL-ON-GROUND PL-SENT-FLAGS
     CALL "CLP-MOVE-SEND" USING CLIENT-STATE WS-CONN
     MOVE 1 TO WS-INDEX
     CALL "TEST-SENT" USING CLIENT-STATE WS-CONN WS-INDEX PB-BUFFER WS-FOUND
     MOVE "movement packets a changed position alone is sent as Move Player Pos "
         & "(play-c2s-1e-move-player-pos.hex)" TO TL-CASE
     MOVE "contract/fixtures/wire/play-c2s-1e-move-player-pos.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT
     CALL "TEST-CLEAR-SENT" USING CLIENT-STATE WS-CONN

     MOVE 4.5 TO PL-SENT-X
     MOVE 45 TO PL-YAW
     MOVE 30 TO PL-PITCH
     CALL "CLP-MOVE-SEND" USING CLIENT-STATE WS-CONN
     CALL "TEST-SENT" USING CLIENT-STATE WS-CONN WS-INDEX PB-BUFFER WS-FOUND
     MOVE "movement packets a changed position and rotation are sent as Move Player Pos Rot "
         & "(play-c2s-1f-move-player-pos-rot.hex)" TO TL-CASE
     MOVE "contract/fixtures/wire/play-c2s-1f-move-player-pos-rot.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT
     CALL "TEST-CLEAR-SENT" USING CLIENT-STATE WS-CONN

     MOVE 0 TO PL-SENT-YAW
     CALL "CLP-MOVE-SEND" USING CLIENT-STATE WS-CONN
     CALL "TEST-SENT" USING CLIENT-STATE WS-CONN WS-INDEX PB-BUFFER WS-FOUND
     MOVE "movement packets a changed rotation alone is sent as Move Player Rot "
         & "(play-c2s-20-move-player-rot.hex)" TO TL-CASE
     MOVE "contract/fixtures/wire/play-c2s-20-move-player-rot.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT
     CALL "TEST-CLEAR-SENT" USING CLIENT-STATE WS-CONN

     MOVE 1 TO PL-COLLIDED
     CALL "CLP-MOVE-SEND" USING CLIENT-STATE WS-CONN
     CALL "TEST-SENT" USING CLIENT-STATE WS-CONN WS-INDEX PB-BUFFER WS-FOUND
     MOVE "movement packets changed MoveFlags alone (horizontal collision) are sent as Move "
         & "Player Status Only (play-c2s-21-move-player-status-only.hex)" TO TL-CASE
     MOVE "contract/fixtures/wire/play-c2s-21-move-player-status-only.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT
     CALL "TEST-CLEAR-SENT" USING CLIENT-STATE WS-CONN

     CALL "CLP-MOVE-SEND" USING CLIENT-STATE WS-CONN
     CALL "TEST-SENT" USING CLIENT-STATE WS-CONN WS-INDEX PB-BUFFER WS-FOUND
     MOVE "movement packets nothing changed: nothing is sent" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A server correction while falling.
     MOVE -0.5 TO PL-VY
     MOVE "contract/fixtures/wire/play-s2c-49-player-position.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     CALL "TEST-SENT" USING CLIENT-STATE WS-CONN WS-INDEX PB-BUFFER WS-FOUND
     MOVE "movement packets a server Player Position is accepted "
         & "(play-c2s-00-accept-teleportation.hex)" TO TL-CASE
     MOVE "contract/fixtures/wire/play-c2s-00-accept-teleportation.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT
     CALL "TEST-CLEAR-SENT" USING CLIENT-STATE WS-CONN
     CALL "CLP-MOVE-SEND" USING CLIENT-STATE WS-CONN
     CALL "TEST-SENT" USING CLIENT-STATE WS-CONN WS-INDEX PB-BUFFER WS-FOUND
     MOVE "movement packets a server Player Position corrects the position (4.5, 54, 8.5), yaw "
         & "-90, stops the fall and is not echoed as a move" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     CALL "TEST-POSITION" USING CLIENT-STATE TL-OBSERVED
     CALL "TEST-ANGLES" USING CLIENT-STATE TL-OBSERVED
     STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION CHAR(WS-FOUND + 49) DELIMITED BY SIZE
         INTO TL-OBSERVED
     IF PL-VY NOT = 0
         MOVE "still falling" TO TL-OBSERVED
     END-IF
     MOVE "4.5000/54.0000/8.5000 -90.0/0.0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Each client tick in play: the move, then Client Tick End.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-DOWN
     CALL "TEST-SERVER-READ" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE "movement packets a tick walking sends Move Player Pos before Client Tick End" TO TL-CASE
     MOVE "1e 0d" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-UP
     CALL "TEST-SERVER-READ" USING WS-SERVER WS-TEXT WS-THRESHOLD
     INITIALIZE WS-EVENT
     MOVE CC-EV-CURSOR TO WS-KIND
     MOVE 100 TO WS-DX
     CALL "TEST-EVENTS-MS" USING CLIENT-STATE WS-EVENT WS-ONE WS-MS
     CALL "TEST-SERVER-READ" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE "movement packets a tick turning in place sends Move Player Rot before Client Tick End"
         TO TL-CASE
     MOVE "20 0d" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-TICKS" USING CLIENT-STATE WS-ONE
     CALL "TEST-SERVER-READ" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE "movement packets a tick standing still sends Client Tick End only" TO TL-CASE
     MOVE "0d" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-MOVEMENT-PACKETS.
 COPY CLTEST.
