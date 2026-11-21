*> Acceptance test, US15-2 server half: the stop sequence (contracts/operator-surface.md §3, §4;
*> core-host-api.md §2; standin-content §16.2 row 29, §17). acc_us15_stop.stdin holds the §16 stop
*> command (stop). The test starts the server in-process and brings a loopback player into play
*> while it holds the console back (SV-CONSOLE-OPEN 0), then lets the console be read and forks: the
*> child runs the loop (SV-RUN, stdout to stdout.txt) and must end the run itself; the parent is the
*> player. Runs in build/server-test-us15-stop.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US15-STOP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY COREAPI.
 COPY SVSTATE.
 COPY TESTLIB.
 COPY PROTO REPLACING LEADING ==PB-== BY ==ST-==.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 COPY PROTO REPLACING LEADING ==PB-== BY ==LS-==.
 01 WS-SCRATCH             PIC X(256) VALUE "build/server-test-us15-stop".
 01 WS-CONF                PIC X(4096) VALUE "port=25577|hostile-mobs=false".
 01 WS-CAPTURE             PIC X(256) VALUE "stdout.txt".
 01 WS-CAPTURED            PIC X(4096).
 01 WS-STDERR              PIC X(4096).
 01 WS-CHECK               PIC X(256) VALUE "test -f world/level.dat && test -f world/access.dat"
     & " && test 1 -eq $(ls world/players/*.dat | wc -l)".
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-PORT                BINARY-LONG VALUE 25577.
 01 WS-ALICE               BINARY-LONG.
 01 WS-PATH                PIC X(256).
 01 WS-NONE                BINARY-LONG VALUE -1.
 01 WS-COMPRESSED          BINARY-LONG VALUE 256.
 01 WS-WAIT                BINARY-LONG VALUE 10.
 01 WS-LONG-WAIT           BINARY-LONG VALUE 50.
 01 WS-CLOSED              BINARY-LONG.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-LAST-ID             BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-QUIET               BINARY-LONG.
 01 WS-ROUNDS              BINARY-LONG.
 01 WS-BEFORE              BINARY-LONG.
 01 WS-PID                 BINARY-LONG.
 01 WS-EXIT                BINARY-LONG.
 01 WS-FILES               BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-EDIT2               PIC -(9)9.
 01 B-AREA                 PIC X(65536) BASED.
 PROCEDURE DIVISION.
     CALL "PB-INIT" USING ST-BUFFER WS-CAPACITY
     CALL "PB-INIT" USING PK-BUFFER WS-CAPACITY
     CALL "PB-INIT" USING LS-BUFFER WS-CAPACITY
     CALL "SVT-SCRATCH" USING WS-SCRATCH
     CALL "SVT-WRITE-CONF" USING WS-CONF
     CALL "SV-START"
     MOVE 0 TO SV-CONSOLE-OPEN

*>   Given a connected loopback player in play (everything sent to her received).
     CALL "SVT-CONNECT" USING WS-PORT WS-ALICE
     MOVE "contract/fixtures/wire/handshake-c2s-00-intention-login.hex" TO WS-PATH
     CALL "SVT-SEND-FIXTURE" USING WS-ALICE WS-PATH WS-NONE
     MOVE "contract/fixtures/wire/login-c2s-00-hello.hex" TO WS-PATH
     CALL "SVT-SEND-FIXTURE" USING WS-ALICE WS-PATH WS-NONE
     PERFORM 5 TIMES
         PERFORM ITERATE-AND-RECEIVE
     END-PERFORM
     CALL "SVT-CONFIGURE" USING WS-ALICE
     MOVE 0 TO WS-QUIET WS-ROUNDS
     PERFORM UNTIL WS-QUIET >= 5 OR WS-ROUNDS > 500
         MOVE ST-LENGTH TO WS-BEFORE
         PERFORM ITERATE-AND-RECEIVE
         ADD 1 TO WS-ROUNDS
         IF ST-LENGTH = WS-BEFORE
             ADD 1 TO WS-QUIET
         ELSE
             MOVE 0 TO WS-QUIET
         END-IF
     END-PERFORM
     CALL "CORE-STATUS-GET" USING CORE-STATUS
     MOVE "acceptance US15-2 given a connected loopback player in play" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE CST-PLAYERS-ONLINE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   When stop is typed: the console is read again and the loop runs in a child process.
     CALL "PB-RESET" USING ST-BUFFER
     MOVE 1 TO SV-CONSOLE-OPEN
     CALL "SVT-FORK" USING WS-PID
     IF WS-PID = 0
         CALL "SVT-CAPTURE-START" USING WS-CAPTURE
         CALL "SV-RUN"
         STOP RUN RETURNING 9
     END-IF
*>   The parent's copies of the server's sockets are closed, so only the child holds them.
     CALL "SV-SHUTDOWN"
     MOVE 0 TO WS-CLOSED WS-ROUNDS
     PERFORM UNTIL WS-CLOSED = 1 OR WS-ROUNDS > 200
         CALL "SVT-RECV" USING WS-ALICE ST-BUFFER WS-LONG-WAIT WS-CLOSED
         ADD 1 TO WS-ROUNDS
     END-PERFORM
     CALL "SVT-WAIT" USING WS-PID WS-EXIT WS-STDERR

*>   Then the player receives the stopping Disconnect last, and the connection ends.
     MOVE 0 TO WS-OUTCOME
     MOVE -1 TO WS-LAST-ID
     PERFORM UNTIL WS-OUTCOME NOT = 0
         CALL "SVT-NEXT-PACKET" USING ST-BUFFER PK-BUFFER WS-COMPRESSED WS-PACKET-ID WS-OUTCOME
         IF WS-OUTCOME = 0
             MOVE WS-PACKET-ID TO WS-LAST-ID
             CALL "PB-RESET" USING LS-BUFFER
             SET ADDRESS OF B-AREA TO PK-ADDR
             CALL "PB-APPEND-BYTES" USING LS-BUFFER B-AREA PK-LENGTH
         END-IF
     END-PERFORM
     MOVE "acceptance US15-2 when stop is typed then the player's connection ends" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-CLOSED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15-2 when stop is typed then the player receives the stopping Disconnect "
         & "as the last packet" TO TL-CASE
     MOVE "contract/fixtures/wire/play-s2c-20-disconnect-stopping.hex" TO WS-PATH
     CALL "SVT-SAME-AS-FIXTURE" USING LS-BUFFER WS-PATH TESTLIB-ASSERT

*>   Then the console shows the command's result, Stopping, the player's leave line (operator-
*>   surface §3: she leaves as she is disconnected) and Stopped.
     CALL "SVT-READ-LINES" USING WS-CAPTURE WS-CAPTURED
     CALL "SVT-UNSTAMP" USING WS-CAPTURED
     MOVE "acceptance US15-2 when stop is typed then the console shows Stopping: saving world and "
         & "disconnecting players, then Stopped" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "Stopping the server | Stopping: saving world and disconnecting players | Alice left | Stopped"
         TO TL-EXPECTED
     MOVE WS-CAPTURED TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Then the world files exist and the loop ended the run with exit status 0.
     CALL "SYSTEM" USING WS-CHECK
     MOVE RETURN-CODE TO WS-FILES
     MOVE 0 TO RETURN-CODE
     MOVE "acceptance US15-2 when stop is typed then level.dat, access.dat and the player's file "
         & "exist and the loop ends with exit status 0" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "files 0 exit 0 stderr" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-FILES TO WS-EDIT
     MOVE WS-EXIT TO WS-EDIT2
     STRING "files " FUNCTION TRIM(WS-EDIT) " exit " FUNCTION TRIM(WS-EDIT2) " stderr "
         FUNCTION TRIM(WS-STDERR) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL STATIC "cc_net_close" USING BY VALUE WS-ALICE
     CALL "SVT-HOME"
     STOP RUN.

 ITERATE-AND-RECEIVE.
     CALL "SV-ITERATE"
     CALL "SVT-RECV" USING WS-ALICE ST-BUFFER WS-WAIT WS-CLOSED.
 END PROGRAM ACC-US15-STOP.
 COPY SVTEST.
