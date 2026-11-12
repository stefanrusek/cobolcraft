*> Acceptance test, US15-1 and US15-3 server half: console input (contracts/operator-surface.md §4;
*> standin-content §16). acc_us15_console.stdin holds the player-list command (list), a blank
*> line, an operator-only command (banlist) and an unknown command, then the end of input. Each typed
*> line runs as a command of the command set with operator permission and its result or error text
*> is printed; the blank line runs nothing; the end of input has no effect on the running server.
*> Runs in build/server-test-us15-console.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US15-CONSOLE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY COREAPI.
 COPY SVSTATE.
 COPY TESTLIB.
 COPY PROTO REPLACING LEADING ==PB-== BY ==ST-==.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 01 WS-SCRATCH             PIC X(256) VALUE "build/server-test-us15-console".
 01 WS-CONF                PIC X(4096) VALUE "port=25576".
 01 WS-CAPTURE             PIC X(256) VALUE "stdout.txt".
 01 WS-CAPTURED            PIC X(4096).
 01 WS-LINES.
    05 WS-LINE             PIC X(256) OCCURS 5 TIMES.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-PORT                BINARY-LONG VALUE 25576.
 01 WS-CLIENT              BINARY-LONG.
 01 WS-PATH                PIC X(256).
 01 WS-NONE                BINARY-LONG VALUE -1.
 01 WS-WAIT                BINARY-LONG VALUE 10.
 01 WS-CLOSED              BINARY-LONG.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-START               BINARY-DOUBLE.
 01 WS-NOW                 BINARY-DOUBLE.
 01 WS-TICKS               BINARY-DOUBLE.
 01 WS-EDIT                PIC -(9)9.
 01 WS-EDIT2               PIC -(9)9.
 01 WS-EDIT3               PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "PB-INIT" USING ST-BUFFER WS-CAPACITY
     CALL "PB-INIT" USING PK-BUFFER WS-CAPACITY
     CALL "SVT-SCRATCH" USING WS-SCRATCH
     CALL "SVT-WRITE-CONF" USING WS-CONF
     CALL "SV-START"

*>   Given the lines on standard input, when the server iterates, then each runs and its result is
*>   printed, in the order typed.
     CALL "SVT-CAPTURE-START" USING WS-CAPTURE
     PERFORM 5 TIMES
         CALL "SV-ITERATE"
     END-PERFORM
     CALL "SVT-CAPTURE-STOP" USING WS-CAPTURE WS-CAPTURED
     CALL "SVT-UNSTAMP" USING WS-CAPTURED
     MOVE SPACES TO WS-LINES
     UNSTRING WS-CAPTURED DELIMITED BY " | " INTO WS-LINE(1) WS-LINE(2) WS-LINE(3) WS-LINE(4)
         WS-LINE(5)
     MOVE "acceptance US15-1 given the server running when list and the operator command banlist "
         & "are typed at the console then they run with operator permission and their results are "
         & "printed" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "There are 0 of a max of 64 players online: | There are no bans" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-LINE(1)) " | " FUNCTION TRIM(WS-LINE(2)) DELIMITED BY SIZE
         INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15-3 given the server running when an unknown command is typed then the "
         & "error and the help hint are printed, and the blank line runs nothing" TO TL-CASE
     MOVE "Unknown or incomplete command. See below for error | (no more lines)"
         TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     IF WS-LINE(4) = SPACES
         MOVE "(no more lines)" TO WS-LINE(4)
     END-IF
     STRING FUNCTION TRIM(WS-LINE(3)) " | " FUNCTION TRIM(WS-LINE(4)) DELIMITED BY SIZE
         INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   End of input: the server keeps running. It is not stopped, idle iterations still wait for the
*>   next tick (10 take about 10 ticks, not a busy loop on the closed input), ticks keep running
*>   and a client is still served.
     CALL "SVT-NOW-MS" USING WS-START
     MOVE SV-TICKS TO WS-TICKS
     PERFORM 10 TIMES
         CALL "SV-ITERATE"
     END-PERFORM
     CALL "SVT-NOW-MS" USING WS-NOW
     COMPUTE WS-TICKS = SV-TICKS - WS-TICKS
     CALL "SVT-CONNECT" USING WS-PORT WS-CLIENT
     MOVE "contract/fixtures/wire/handshake-c2s-00-intention-status.hex" TO WS-PATH
     CALL "SVT-SEND-FIXTURE" USING WS-CLIENT WS-PATH WS-NONE
     MOVE "contract/fixtures/wire/status-c2s-00-status-request.hex" TO WS-PATH
     CALL "SVT-SEND-FIXTURE" USING WS-CLIENT WS-PATH WS-NONE
     PERFORM 10 TIMES
         CALL "SV-ITERATE"
         CALL "SVT-RECV" USING WS-CLIENT ST-BUFFER WS-WAIT WS-CLOSED
     END-PERFORM
     CALL "SVT-NEXT-PACKET" USING ST-BUFFER PK-BUFFER WS-NONE WS-PACKET-ID WS-OUTCOME
     CALL "CORE-STATUS-GET" USING CORE-STATUS
     MOVE "acceptance US15 given the end of console input when the server goes on then it has no "
         & "effect: still running, iterations wait for ticks, ticks run, clients are served" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "run 0 waits ticks status response" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE CST-RUN-STATE TO WS-EDIT
     COMPUTE WS-EDIT2 = WS-NOW - WS-START
     MOVE WS-TICKS TO WS-EDIT3
     STRING "run " FUNCTION TRIM(WS-EDIT) " elapsed " FUNCTION TRIM(WS-EDIT2) " ticks "
         FUNCTION TRIM(WS-EDIT3) DELIMITED BY SIZE INTO TL-OBSERVED
     IF CST-RUN-STATE = 0 AND WS-NOW - WS-START >= 400 AND WS-TICKS >= 8
             AND WS-OUTCOME = 0 AND WS-PACKET-ID = 0
         MOVE "run 0 waits ticks status response" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL STATIC "cc_net_close" USING BY VALUE WS-CLIENT
     CALL "SV-SHUTDOWN"
     CALL "SVT-HOME"
     STOP RUN.
 END PROGRAM ACC-US15-CONSOLE.
 COPY SVTEST.
