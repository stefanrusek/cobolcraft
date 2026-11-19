*> Test of the single-player role of the server program (server/src/hosted.cob, loop.cob, console.cob; docs/design/singleplayer-process.md): the control lines
*> @pause and @resume hold and release the tick clock (a paused iteration runs no tick, resuming does not catch up), an unknown control line is ignored,
*> in the role at most 3 ticks run an iteration and a debt of more than 250 ms is dropped, lines of the console starting with @ are control lines (the
*> others commands) and the end of input asks for a stop, "@stop-requested" is printed once, the @load line is printed while the spawn is prepared and once
*> more when it has ended, @open moves the listener, the console lines carry no time stamp, and @stop makes the next iteration run the stop sequence
*> (run state 2). The standard input (test_sv_hosted_control.stdin) holds "@pause", the command "list" and the end of input. Runs in build/server-test-hosted.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SV-HOSTED-CONTROL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY COREAPI.
 COPY SVSTATE.
 COPY TESTLIB.
 01 WS-SCRATCH             PIC X(256) VALUE "build/server-test-hosted".
 01 WS-CAPTURE             PIC X(256) VALUE "stdout.txt".
 01 WS-CAPTURED            PIC X(4096).
 01 WS-CONF                PIC X(4096).
 01 WS-PORT                BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-EDIT2               PIC -(9)9.
 01 WS-EDIT3               PIC -(9)9.
 01 WS-NOW                 BINARY-DOUBLE.
 01 WS-TICKS               BINARY-DOUBLE.
 01 WS-FLAG                BINARY-LONG.
 01 WS-LINE                PIC X(1025).
 01 WS-NOTE                PIC X(512).
 01 WS-TIMEOUT             BINARY-LONG VALUE 200.
 01 WS-OLD-PORT            BINARY-LONG.
 01 WS-HELD                PIC 9.
 01 WS-DELTA               BINARY-DOUBLE.
 PROCEDURE DIVISION.
     CALL "SVT-SCRATCH" USING WS-SCRATCH
     CALL "SVT-FREE-PORT" USING WS-PORT
     MOVE WS-PORT TO WS-EDIT
     MOVE SPACES TO WS-CONF
     STRING "port=" FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-CONF
     CALL "SVT-WRITE-CONF" USING WS-CONF
     CALL "SV-START"
     MOVE 0 TO SV-CONSOLE-OPEN
     MOVE "T" TO TL-MODE

     CALL "SV-HOSTED-ARG" USING WS-FLAG
     MOVE "test sv hosted without --hosted on the command line the program is the dedicated server" TO TL-CASE
     MOVE "flag 0" TO TL-EXPECTED
     MOVE WS-FLAG TO WS-EDIT
     MOVE SPACES TO TL-OBSERVED
     STRING "flag " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Paused: due ticks do not run and the clock is held.
     MOVE "@pause" TO WS-LINE
     MOVE X"00" TO WS-LINE(7:1)
     CALL "SV-CONTROL" USING WS-LINE
     MOVE SV-TICKS TO WS-TICKS
     CALL "SV-NOW-MS" USING WS-NOW
     COMPUTE SV-NEXT-TICK = WS-NOW - 1000
     CALL "SV-ITERATE"
     CALL "SV-NOW-MS" USING WS-NOW
     MOVE SV-PAUSED TO WS-EDIT
     COMPUTE WS-EDIT2 = SV-TICKS - WS-TICKS
     COMPUTE WS-DELTA = SV-NEXT-TICK - WS-NOW
     MOVE WS-DELTA TO WS-EDIT3
     MOVE "test sv hosted @pause: no tick runs although ticks are due, and the clock is held (the next tick is about 50 ms away)" TO TL-CASE
     MOVE "paused 1 ticks 0 held 1" TO TL-EXPECTED
     MOVE 0 TO WS-HELD
     IF WS-DELTA > -100 AND WS-DELTA <= 60
         MOVE 1 TO WS-HELD
     END-IF
     MOVE SPACES TO TL-OBSERVED
     STRING "paused " FUNCTION TRIM(WS-EDIT) " ticks " FUNCTION TRIM(WS-EDIT2) " held " WS-HELD DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   An unknown control line changes nothing; @resume releases the clock from now.
     MOVE "@mystery 1" TO WS-LINE
     MOVE X"00" TO WS-LINE(11:1)
     CALL "SV-CONTROL" USING WS-LINE
     MOVE SV-PAUSED TO WS-EDIT
     MOVE "@resume" TO WS-LINE
     MOVE X"00" TO WS-LINE(8:1)
     CALL "SV-CONTROL" USING WS-LINE
     CALL "SV-NOW-MS" USING WS-NOW
     MOVE SV-PAUSED TO WS-EDIT2
     COMPUTE WS-DELTA = SV-NEXT-TICK - WS-NOW
     MOVE WS-DELTA TO WS-EDIT3
     MOVE "test sv hosted an unknown control line is ignored; @resume releases the pause and starts the clock from now" TO TL-CASE
     MOVE "still paused 1 resumed 0 clock 1" TO TL-EXPECTED
     MOVE 0 TO WS-HELD
     IF WS-DELTA > -100 AND WS-DELTA <= 60
         MOVE 1 TO WS-HELD
     END-IF
     MOVE SPACES TO TL-OBSERVED
     STRING "still paused " FUNCTION TRIM(WS-EDIT) " resumed " FUNCTION TRIM(WS-EDIT2) " clock " WS-HELD DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   In the single-player role an iteration runs at most 3 ticks and drops a debt of more than 250 ms.
     MOVE 1 TO SV-HOSTED
     MOVE SV-TICKS TO WS-TICKS
     CALL "SV-NOW-MS" USING WS-NOW
     COMPUTE SV-NEXT-TICK = WS-NOW - 2000
     CALL "SV-ITERATE"
     CALL "SV-NOW-MS" USING WS-NOW
     COMPUTE WS-EDIT = SV-TICKS - WS-TICKS
     COMPUTE WS-DELTA = SV-NEXT-TICK - WS-NOW
     MOVE WS-DELTA TO WS-EDIT2
     MOVE "test sv hosted with 40 ticks due an iteration runs 3 and drops the debt: the next tick is about 50 ms away" TO TL-CASE
     MOVE "ticks 3 dropped 1" TO TL-EXPECTED
     MOVE 0 TO WS-HELD
     IF WS-DELTA > -1000 AND WS-DELTA <= 60
         MOVE 1 TO WS-HELD
     END-IF
     MOVE SPACES TO TL-OBSERVED
     STRING "ticks " FUNCTION TRIM(WS-EDIT) " dropped " WS-HELD DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Console lines have no time stamp in this role; @stop-requested is printed once; the @load line ends the progress once.
     CALL "SVT-CAPTURE-START" USING WS-CAPTURE
     MOVE "hello" TO WS-NOTE
     CALL "SV-NOTE" USING WS-NOTE
     CALL "SV-HOSTED-ASK"
     CALL "SV-HOSTED-ASK"
     MOVE 1 TO SV-LOAD-STATE
     CALL "SV-NOW-MS" USING WS-NOW
     COMPUTE SV-LOAD-MS = WS-NOW - 500
     CALL "SV-HOSTED-LOAD"
     CALL "SV-HOSTED-LOAD"
     CALL "SVT-CAPTURE-STOP" USING WS-CAPTURE WS-CAPTURED
     MOVE SV-LOAD-STATE TO WS-EDIT2
     MOVE "test sv hosted the console line has no time stamp and @stop-requested is printed once" TO TL-CASE
     MOVE "hello | @stop-requested state 0" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-CAPTURED) " state " FUNCTION TRIM(WS-EDIT2) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The @load line (1250 bytes, more than the capture reader takes) is looked for with grep: exactly one, the final one with its grid.
     CALL "SYSTEM" USING Z"[ $(grep -c '^@load 0 0 49 1000 0 0 A' stdout.txt) -eq 1 ] && [ $(grep -c '^@load' stdout.txt) -eq 1 ]"
     MOVE "test sv hosted one final @load line with the 35 x 35 grid follows the progress (state 0, ready 0 of 49, 1000 permille)" TO TL-CASE
     MOVE "line 1" TO TL-EXPECTED
     MOVE "line 0" TO TL-OBSERVED
     IF RETURN-CODE = 0
         MOVE "line 1" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The console of the role: a line starting with @ is a control line (@pause), any other a command, the end of input asks for a stop.
     MOVE 0 TO SV-PAUSED
     MOVE 1 TO SV-CONSOLE-OPEN
     CALL "TCP-POLL" USING WS-TIMEOUT
     MOVE SV-PAUSED TO WS-EDIT
     MOVE SV-STOP-WANTED TO WS-EDIT2
     MOVE SV-CONSOLE-OPEN TO WS-EDIT3
     MOVE "test sv hosted a console line @pause is a control line, the end of input closes the console and asks for a stop" TO TL-CASE
     MOVE "paused 1 stop 1 console 0" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING "paused " FUNCTION TRIM(WS-EDIT) " stop " FUNCTION TRIM(WS-EDIT2) " console " FUNCTION TRIM(WS-EDIT3)
         DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   @open moves the listener to every interface and says where.
     MOVE 1 TO SV-LOOPBACK
     CALL "SVT-CAPTURE-START" USING WS-CAPTURE
     MOVE "@open 0 0" TO WS-LINE
     MOVE X"00" TO WS-LINE(10:1)
     CALL "SV-CONTROL" USING WS-LINE
     CALL "SVT-CAPTURE-STOP" USING WS-CAPTURE WS-CAPTURED
     MOVE SV-BOUND-PORT TO WS-EDIT
     MOVE SPACES TO TL-EXPECTED
     STRING "loopback 0 line @opened " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE SV-LOOPBACK TO WS-EDIT2
     MOVE "test sv hosted @open puts the listener on every interface at a new port and prints @opened <port>" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING "loopback " FUNCTION TRIM(WS-EDIT2) " line " FUNCTION TRIM(WS-CAPTURED) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   @stop (or the end of input): the next iteration runs the stop sequence, the run state is 2.
     MOVE 0 TO SV-STOP-WANTED
     MOVE "@stop" TO WS-LINE
     MOVE X"00" TO WS-LINE(6:1)
     CALL "SV-CONTROL" USING WS-LINE
     MOVE SV-STOP-WANTED TO WS-EDIT
     CALL "SVT-CAPTURE-START" USING WS-CAPTURE
     CALL "SV-ITERATE"
     CALL "SVT-CAPTURE-STOP" USING WS-CAPTURE WS-CAPTURED
     CALL "CORE-STATUS-GET" USING CORE-STATUS
     MOVE CST-RUN-STATE TO WS-EDIT2
     MOVE "test sv hosted @stop asks for the stop and the next iteration runs it: run state 2" TO TL-CASE
     MOVE "wanted 1 state 2" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING "wanted " FUNCTION TRIM(WS-EDIT) " state " FUNCTION TRIM(WS-EDIT2) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "SV-SHUTDOWN"
     STOP RUN.
 END PROGRAM TEST-SV-HOSTED-CONTROL.
 COPY SVTEST.
