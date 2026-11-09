*> Implementation test of the server's main loop (server/src/loop.cob; research R6; contracts/
*> operator-surface.md §1, §2): SV-START with the default settings opens ./world in the current
*> directory and listens on port 25565; SV-ITERATE waits on cc_net_poll no longer than the time to
*> the next tick, runs every due tick (one per elapsed 50 ms) and displays the drained console lines;
*> SV-SHUTDOWN closes the connections and the listener. Runs in build/server-test-loop.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MAIN-LOOP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY COREAPI.
 COPY SVSTATE.
 COPY CCSHIM.
 COPY TESTLIB.
 COPY PROTO REPLACING LEADING ==PB-== BY ==ST-==.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 01 WS-SCRATCH             PIC X(256) VALUE "build/server-test-loop".
 01 WS-CAPTURE             PIC X(256) VALUE "stdout.txt".
 01 WS-CAPTURED            PIC X(4096).
 01 WS-WORLD-DIR           PIC X(16) VALUE "world".
 01 WS-FILE-INFO           PIC X(16).
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-PORT                BINARY-LONG VALUE 25565.
 01 WS-CLIENT              BINARY-LONG.
 01 WS-LATE                BINARY-LONG.
 01 WS-PATH                PIC X(256).
 01 WS-NONE                BINARY-LONG VALUE -1.
 01 WS-WAIT                BINARY-LONG VALUE 10.
 01 WS-LONG-WAIT           BINARY-LONG VALUE 200.
 01 WS-SLEEP               BINARY-LONG VALUE 300.
 01 WS-CLOSED              BINARY-LONG.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-RC                  BINARY-LONG.
 01 WS-START               BINARY-DOUBLE.
 01 WS-NOW                 BINARY-DOUBLE.
 01 WS-BEFORE              BINARY-DOUBLE.
 01 WS-LONGEST             BINARY-DOUBLE.
 01 WS-TOTAL               BINARY-DOUBLE.
 01 WS-TICKS               BINARY-DOUBLE.
 01 WS-COMMAND             PIC X(64) VALUE Z"nosuchcommand".
 01 WS-EDIT                PIC -(9)9.
 01 WS-EDIT2               PIC -(9)9.
 01 WS-DEFAULTS            PIC X(3829).
 PROCEDURE DIVISION.
     CALL "PB-INIT" USING ST-BUFFER WS-CAPACITY
     CALL "PB-INIT" USING PK-BUFFER WS-CAPACITY
     CALL "SVT-SCRATCH" USING WS-SCRATCH

*>   The operator-surface §2 defaults, written out from the table: creative, "A CobolCraft
*>   server", view distance 8, player combat, hostile mobs, weather changes and extra dimensions
*>   on, allow-list off, no pack offer; a dedicated server (host kind 0).
     INITIALIZE CORE-SETTINGS
     MOVE 1 TO CS-DEFAULT-MODE
     MOVE "A CobolCraft server" TO CS-DESCRIPTION
     MOVE 8 TO CS-VIEW-DISTANCE
     MOVE 1 TO CS-PLAYER-COMBAT CS-HOSTILE-MOBS CS-WEATHER-CHANGES CS-EXTRA-DIMENSIONS
     MOVE 0 TO CS-ALLOW-LIST-ENFORCED CS-PACK-OFFERED CS-PACK-REQUIRED CS-HOST-KIND
     MOVE "world" TO CS-NEW-WORLD-NAME
     MOVE CORE-SETTINGS TO WS-DEFAULTS

     CALL "SV-START"
     MOVE "test main loop SV-START uses the operator-surface §2 default settings and port 25565"
         TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-EXPECTED TL-OBSERVED
     STRING "port 25565 " WS-DEFAULTS(1:200) DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE SV-PORT TO WS-EDIT
     STRING "port " FUNCTION TRIM(WS-EDIT) " " SV-SETTINGS(1:200) DELIMITED BY SIZE
         INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test main loop SV-START keeps the whole default CORE-SETTINGS record" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF SV-SETTINGS = WS-DEFAULTS
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "SVT-CONNECT" USING WS-PORT WS-CLIENT
     CALL STATIC "cc_net_status" USING BY VALUE WS-CLIENT RETURNING WS-RC
     MOVE "test main loop SV-START opens ./world in the current directory and listens on 25565"
         TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "world port 25565 accepting" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     CALL "CBL_CHECK_FILE_EXIST" USING WS-WORLD-DIR WS-FILE-INFO
     IF RETURN-CODE = 0
         MOVE "world" TO TL-OBSERVED
     END-IF
     MOVE 0 TO RETURN-CODE
     MOVE SV-BOUND-PORT TO WS-EDIT
     STRING FUNCTION TRIM(TL-OBSERVED) " port " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE
         INTO TL-OBSERVED
     IF WS-RC = 0
         STRING FUNCTION TRIM(TL-OBSERVED) " accepting" DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A loopback client completes status through SV-ITERATE.
     MOVE "contract/fixtures/wire/handshake-c2s-00-intention-status.hex" TO WS-PATH
     CALL "SVT-SEND-FIXTURE" USING WS-CLIENT WS-PATH WS-NONE
     MOVE "contract/fixtures/wire/status-c2s-00-status-request.hex" TO WS-PATH
     CALL "SVT-SEND-FIXTURE" USING WS-CLIENT WS-PATH WS-NONE
     PERFORM 10 TIMES
         CALL "SV-ITERATE"
         CALL "SVT-RECV" USING WS-CLIENT ST-BUFFER WS-WAIT WS-CLOSED
     END-PERFORM
     CALL "SVT-NEXT-PACKET" USING ST-BUFFER PK-BUFFER WS-NONE WS-PACKET-ID WS-OUTCOME
     MOVE "test main loop SV-ITERATE accepts, pumps and flushes: the client gets Status Response"
         TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-OUTCOME * 1000 + WS-PACKET-ID
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Idle iterations: each returns by the next tick (at most 50 ms plus the clock's 10 ms
*>   resolution and scheduling), and they do wait: 10 of them take about 10 ticks.
     MOVE 0 TO WS-LONGEST
     CALL "SVT-NOW-MS" USING WS-START
     PERFORM 10 TIMES
         CALL "SVT-NOW-MS" USING WS-BEFORE
         CALL "SV-ITERATE"
         CALL "SVT-NOW-MS" USING WS-NOW
         IF WS-NOW - WS-BEFORE > WS-LONGEST
             COMPUTE WS-LONGEST = WS-NOW - WS-BEFORE
         END-IF
     END-PERFORM
     COMPUTE WS-TOTAL = WS-NOW - WS-START
     MOVE "test main loop an idle SV-ITERATE waits no longer than the time to the next tick (<= 70 "
         & "ms) and 10 of them take 400 to 700 ms" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "longest ok total ok" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-LONGEST TO WS-EDIT
     MOVE WS-TOTAL TO WS-EDIT2
     STRING "longest " FUNCTION TRIM(WS-EDIT) " total " FUNCTION TRIM(WS-EDIT2)
         DELIMITED BY SIZE INTO TL-OBSERVED
     IF WS-LONGEST <= 70 AND WS-TOTAL >= 400 AND WS-TOTAL <= 700
         MOVE "longest ok total ok" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Cadence: 20 ticks per second (18 to 22).
     MOVE SV-TICKS TO WS-TICKS
     CALL "SVT-NOW-MS" USING WS-START
     MOVE WS-START TO WS-NOW
     PERFORM UNTIL WS-NOW - WS-START >= 1000
         CALL "SV-ITERATE"
         CALL "SVT-NOW-MS" USING WS-NOW
     END-PERFORM
     COMPUTE WS-TICKS = SV-TICKS - WS-TICKS
     MOVE "test main loop SV-ITERATE runs one CORE-TICK per elapsed 50 ms: 18 to 22 in a second"
         TO TL-CASE
     MOVE "in range" TO TL-EXPECTED
     MOVE WS-TICKS TO WS-EDIT
     MOVE WS-EDIT TO TL-OBSERVED
     IF WS-TICKS >= 18 AND WS-TICKS <= 22
         MOVE "in range" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Every due tick: after 300 ms without iterating, one SV-ITERATE runs the 6 (or 7) due ticks.
     CALL "SV-ITERATE"
     MOVE SV-TICKS TO WS-TICKS
     CALL "SVT-SLEEP-MS" USING WS-SLEEP
     CALL "SV-ITERATE"
     COMPUTE WS-TICKS = SV-TICKS - WS-TICKS
     MOVE "test main loop after 300 ms one SV-ITERATE runs every due tick (6 or 7)" TO TL-CASE
     MOVE "in range" TO TL-EXPECTED
     MOVE WS-TICKS TO WS-EDIT
     MOVE WS-EDIT TO TL-OBSERVED
     IF WS-TICKS >= 6 AND WS-TICKS <= 7
         MOVE "in range" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Drained console lines are displayed: the result of a console command (08 en_us text of
*>   cobolcraft.command.unknown, standin-content §16.4).
     CALL "CORE-CONSOLE" USING WS-COMMAND
     CALL "SVT-CAPTURE-START" USING WS-CAPTURE
     CALL "SV-ITERATE"
     CALL "SVT-CAPTURE-STOP" USING WS-CAPTURE WS-CAPTURED
     CALL "SVT-UNSTAMP" USING WS-CAPTURED
     MOVE "test main loop SV-ITERATE displays the drained console lines" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "Unknown command nosuchcommand (howto lists the commands)" TO TL-EXPECTED
     MOVE WS-CAPTURED TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   SV-SHUTDOWN: the connected client sees the end of the stream, new connections are refused.
     CALL "SV-SHUTDOWN"
     CALL "PB-RESET" USING ST-BUFFER
     CALL "SVT-RECV" USING WS-CLIENT ST-BUFFER WS-LONG-WAIT WS-CLOSED
     CALL "SVT-CONNECT" USING WS-PORT WS-LATE
     CALL STATIC "cc_net_status" USING BY VALUE WS-LATE RETURNING WS-RC
     MOVE "test main loop SV-SHUTDOWN closes every connection and the listener" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "closed 1 refused 4 listener 0" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-CLOSED TO WS-EDIT
     MOVE WS-RC TO WS-EDIT2
     STRING "closed " FUNCTION TRIM(WS-EDIT) " refused " FUNCTION TRIM(WS-EDIT2)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE SV-LISTENER TO WS-EDIT
     STRING FUNCTION TRIM(TL-OBSERVED) " listener " FUNCTION TRIM(WS-EDIT)
         DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL STATIC "cc_net_close" USING BY VALUE WS-CLIENT
     CALL STATIC "cc_net_close" USING BY VALUE WS-LATE
     STOP RUN.
 END PROGRAM TEST-MAIN-LOOP.
 COPY SVTEST.
