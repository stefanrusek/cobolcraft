*> Implementation test of the client's wait after Login (docs/protocol/50 section 7; client/src/load-wait.cob): Game Event 13 starts the wait, the loading screen
*> shows while it lasts, the wait ends when the section of the camera is meshed (or after 30 s, or the camera is outside the build height, or the player is a
*> spectator or dead), and Player Loaded goes out once the close delay (500 ms for a newly created local world) has passed; then the world screen shows.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-LOAD-WAIT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/client-test-load-wait".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 27.
 01 WS-FOLDER              PIC X(80) VALUE "Wait".
 01 WS-FOLDER-LENGTH       BINARY-LONG VALUE 4.
 01 WS-NAME                PIC X(64) VALUE "Wait".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 4.
 01 WS-MODE                BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-I                   BINARY-LONG.
 01 WS-SEEN-WAIT           BINARY-LONG.
 01 WS-SCREEN-AT-WAIT      BINARY-LONG.
 01 WS-LOADED-EARLY        BINARY-LONG.
 01 WS-READY-AT            BINARY-DOUBLE.
 01 WS-SENT-AT             BINARY-DOUBLE.
 01 WS-ROW                 BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-SEC                 BINARY-LONG.
 01 WS-MESHED              BINARY-LONG.
 01 WS-DEADLINE            BINARY-DOUBLE.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "TEST-SP-START" USING CLIENT-STATE WS-DIR WS-DIR-LENGTH
     CALL "SP-OPEN" USING CLIENT-STATE WS-FOLDER WS-FOLDER-LENGTH WS-NAME WS-NAME-LENGTH WS-MODE

*>   tick by tick through the join
     MOVE 0 TO WS-SEEN-WAIT WS-SCREEN-AT-WAIT WS-LOADED-EARLY WS-READY-AT WS-SENT-AT WS-MESHED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 600 OR PL-LOADED = 1
         CALL "TEST-TICKS" USING CLIENT-STATE WS-ONE
         IF PL-WAIT = 1 AND WS-SEEN-WAIT = 0
             MOVE 1 TO WS-SEEN-WAIT
             MOVE SM-SCREEN TO WS-SCREEN-AT-WAIT
         END-IF
         IF PL-WAIT = 2 AND WS-READY-AT = 0
             MOVE CL-NOW-MS TO WS-READY-AT
             COMPUTE WS-CX = FUNCTION INTEGER(PL-X / 16)
             COMPUTE WS-CZ = FUNCTION INTEGER(PL-Z / 16)
             CALL "WORLD-ROW" USING CLIENT-STATE WS-CX WS-CZ WS-ROW
             COMPUTE WS-SEC = FUNCTION INTEGER((PL-Y + 1.62 - PL-MIN-Y) / 16) + 1
             IF WS-ROW > 0
                 IF WR-DIRTY(WS-ROW, WS-SEC) = 0
                     MOVE 1 TO WS-MESHED
                 END-IF
             END-IF
         END-IF
         IF PL-LOADED = 1
             MOVE CL-NOW-MS TO WS-SENT-AT
         END-IF
         IF PL-LOADED = 1 AND WS-SEEN-WAIT = 0
             MOVE 1 TO WS-LOADED-EARLY
         END-IF
     END-PERFORM
     MOVE "load wait after Game Event 13 the client waits and shows the loading screen" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-SEEN-WAIT * 100 + WS-SCREEN-AT-WAIT
     COMPUTE TL-EXPECTED-N = 100 + SCR-CONNECTING
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "load wait the wait ended because the section of the camera was meshed" TO TL-CASE
     MOVE WS-MESHED TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "load wait in a newly created local world Player Loaded goes out 500 ms after the wait ended" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-SENT-AT - WS-READY-AT
     MOVE 500 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "load wait once Player Loaded is sent the world screen shows" TO TL-CASE
     COMPUTE TL-OBSERVED-N = PL-LOADED * 100 + SM-SCREEN
     COMPUTE TL-EXPECTED-N = 100 + SCR-WORLD
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the conditions, one at a time: a new wait, positioned, before the deadline, the camera section not meshed
     PERFORM NEW-WAIT
     CALL "LOAD-WAIT-TICK" USING CLIENT-STATE
     MOVE "load wait with the camera section missing and time left the wait goes on" TO TL-CASE
     MOVE PL-WAIT TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "load wait before the player is positioned the wait goes on" TO TL-CASE
     PERFORM NEW-WAIT
     MOVE 0 TO PL-POSITIONED
     CALL "LOAD-WAIT-TICK" USING CLIENT-STATE
     MOVE PL-WAIT TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     PERFORM NEW-WAIT
     COMPUTE CL-NOW-MS = PL-WAIT-START + 30001
     CALL "LOAD-WAIT-TICK" USING CLIENT-STATE
     MOVE "load wait after 30 s the wait ends (the player is let in anyway)" TO TL-CASE
     MOVE PL-WAIT TO TL-OBSERVED-N
     MOVE 2 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM NEW-WAIT
     COMPUTE CL-NOW-MS = PL-WAIT-START + 30000
     CALL "LOAD-WAIT-TICK" USING CLIENT-STATE
     MOVE "load wait at exactly 30 s the wait goes on" TO TL-CASE
     MOVE PL-WAIT TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     PERFORM NEW-WAIT
     MOVE 10000 TO PL-Y
     CALL "LOAD-WAIT-TICK" USING CLIENT-STATE
     MOVE "load wait with the camera above the build height the wait ends" TO TL-CASE
     MOVE PL-WAIT TO TL-OBSERVED-N
     MOVE 2 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM NEW-WAIT
     MOVE 3 TO PL-MODE
     CALL "LOAD-WAIT-TICK" USING CLIENT-STATE
     MOVE "load wait for a spectator the wait ends" TO TL-CASE
     MOVE PL-WAIT TO TL-OBSERVED-N
     MOVE 2 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM NEW-WAIT
     MOVE 0 TO PL-HEALTH
     CALL "LOAD-WAIT-TICK" USING CLIENT-STATE
     MOVE "load wait for a dead player the wait ends" TO TL-CASE
     MOVE PL-WAIT TO TL-OBSERVED-N
     MOVE 2 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the close delay: 499 ms after the wait ended nothing is sent, at 500 ms Player Loaded goes out
     PERFORM NEW-WAIT
     MOVE 2 TO PL-WAIT
     MOVE 1000 TO PL-READY-AT
     MOVE 500 TO PL-CLOSE-DELAY
     MOVE 1499 TO CL-NOW-MS
     CALL "LOAD-WAIT-TICK" USING CLIENT-STATE
     MOVE "load wait with a close delay of 500 ms nothing is sent after 499 ms" TO TL-CASE
     COMPUTE TL-OBSERVED-N = PL-LOADED * 10 + PL-WAIT
     MOVE 2 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1500 TO CL-NOW-MS
     CALL "LOAD-WAIT-TICK" USING CLIENT-STATE
     MOVE "load wait after 500 ms Player Loaded is sent and the wait is over" TO TL-CASE
     COMPUTE TL-OBSERVED-N = PL-LOADED * 10 + PL-WAIT
     MOVE 10 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> A wait just begun at the current clock: positioned in a chunk that is not in the replica, health and mode normal, not loaded.
 NEW-WAIT.
     MOVE 1 TO PL-WAIT
     MOVE 0 TO PL-LOADED
     MOVE 500 TO PL-CLOSE-DELAY
     MOVE 1 TO PL-POSITIONED
     MOVE 1000 TO PL-WAIT-START
     MOVE 1000 TO CL-NOW-MS
     MOVE 20 TO PL-HEALTH
     MOVE 1 TO PL-MODE
     MOVE 9999 TO PL-X
     MOVE 9999 TO PL-Z
     MOVE 64 TO PL-Y
     MOVE 0 TO PL-MIN-Y
     MOVE 256 TO PL-HEIGHT.
 END PROGRAM TEST-LOAD-WAIT.
 COPY CLTEST.
