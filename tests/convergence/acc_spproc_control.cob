*> Convergence acceptance test of the controls of a single-player world in a child process (lane spproc, docs/design/singleplayer-process.md):
*> the pause menu pauses the child's ticks (an explicit @pause and @resume, no signals), the game time of the hosted world standing
*> still while it is open and running on after Resume; Open to Others in this mode moves the child's listener to every interface
*> (a second client joins on the reported port as a guest in the chosen game mode) and the pause menu no longer pauses; the stop
*> command ends the world through the client's quit path (the child reports it, the client answers with @stop). The game time
*> comes from the world's own console (time query gametime), sent to the child and read from the lines it prints back.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-SPPROC-CONTROL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONVH.
 COPY CLCONST.
 COPY CCSHIM.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/conv-spproc-control".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 25.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-FOLDER              PIC X(80) VALUE "Control".
 01 WS-FOLDER-LENGTH       BINARY-LONG VALUE 7.
 01 WS-SURVIVAL            BINARY-LONG VALUE 0.
 01 WS-ALICE               BINARY-LONG.
 01 WS-BOBBY               BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-JOINED              BINARY-LONG.
 01 WS-JOINED2             BINARY-LONG.
 01 WS-PID                 BINARY-LONG.
 01 WS-GONE                BINARY-LONG.
 01 WS-T0                  BINARY-LONG.
 01 WS-T1                  BINARY-LONG.
 01 WS-T2                  BINARY-LONG.
 01 WS-T3                  BINARY-LONG.
 01 WS-T4                  BINARY-LONG.
 01 WS-T5                  BINARY-LONG.
 01 WS-T6                  BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-KEY                 BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-ARG                 BINARY-LONG VALUE 0.
 01 WS-FOUND               BINARY-LONG.
 01 WS-SCREEN              BINARY-LONG.
 01 WS-REACHED             BINARY-LONG.
 01 WS-PORT                BINARY-LONG.
 01 WS-LINE                PIC X(64).
 01 WS-LINE-LENGTH         BINARY-LONG.
 01 WS-FRAMES              BINARY-LONG VALUE 60.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-E4                  PIC -(9)9.
 01 WS-E5                  PIC -(9)9.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION.
     CALL "PS-ENSURE-SERVER"
     CALL "CV-INIT" USING CONVH WS-DIR WS-DIR-LENGTH
     MOVE "Alice" TO WS-NAME
     CALL "CV-CLIENT-ADD" USING CONVH WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE "Bobby" TO WS-NAME
     CALL "CV-CLIENT-ADD" USING CONVH WS-NAME WS-NAME-LENGTH WS-BOBBY
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE 1 TO SP-PROCESS-PREF
     CALL "CV-HOST-OPEN" USING CONVH WS-ALICE WS-FOLDER WS-FOLDER-LENGTH WS-SURVIVAL
     CALL "PS-UNTIL-PLAY" USING CONVH WS-ALICE WS-JOINED
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE SP-CHILD-PID TO WS-PID

*>   Running: the game time moves on.
     CALL "PS-GAMETIME" USING CONVH WS-ALICE WS-T0 WS-ONE
     CALL "PS-STEPS" USING CONVH WS-FRAMES
     CALL "PS-GAMETIME" USING CONVH WS-ALICE WS-T1 WS-ZERO
     MOVE "acceptance SPC-1 given a world in a child when the Player plays then its game time moves on (the child ticks)" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "advanced 1" TO TL-EXPECTED
     MOVE 0 TO WS-N
     IF WS-T0 >= 0 AND WS-T1 > WS-T0 + 10
         MOVE 1 TO WS-N
     END-IF
     MOVE WS-N TO WS-E1
     MOVE SPACES TO TL-OBSERVED
     STRING "advanced " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Paused: the pause menu (Escape) sends @pause; the time stands still.
     MOVE CC-KEY-ESCAPE TO WS-KEY
     CALL "CV-KEY" USING CONVH WS-ALICE WS-KEY
     CALL "PS-STEPS" USING CONVH WS-FRAMES
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE SM-SCREEN TO WS-E1
     MOVE SP-PAUSED TO WS-E2
     MOVE SP-PAUSE-SENT TO WS-E3
     CALL "PS-GAMETIME" USING CONVH WS-ALICE WS-T2 WS-ZERO
     CALL "PS-STEPS" USING CONVH WS-FRAMES
     CALL "PS-GAMETIME" USING CONVH WS-ALICE WS-T3 WS-ZERO
     MOVE "acceptance SPC-2 given a world in a child when the pause menu opens then the child stops ticking: the game time "
         & "stands still over 60 frames" TO TL-CASE
     MOVE "screen 9 paused 1 sent 1 same 1" TO TL-EXPECTED
     MOVE 0 TO WS-N
     IF WS-T2 >= 0 AND WS-T3 = WS-T2
         MOVE 1 TO WS-N
     END-IF
     MOVE WS-N TO WS-E4
     MOVE SPACES TO TL-OBSERVED
     STRING "screen " FUNCTION TRIM(WS-E1) " paused " FUNCTION TRIM(WS-E2) " sent " FUNCTION TRIM(WS-E3)
         " same " FUNCTION TRIM(WS-E4) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Resumed: Back to Game sends @resume; the time runs on without catching up.
     MOVE ACT-RESUME TO WS-ACTION
     CALL "CV-CLICK" USING CONVH WS-ALICE WS-ACTION WS-ARG WS-FOUND
     CALL "PS-STEPS" USING CONVH WS-FRAMES
     CALL "PS-GAMETIME" USING CONVH WS-ALICE WS-T4 WS-ZERO
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE "acceptance SPC-3 given the pause menu is open when the Player goes back to the game then the child ticks again "
         & "and the time did not catch up the paused seconds" TO TL-CASE
     MOVE "paused 0 sent 0 advanced 1 caught-up 0" TO TL-EXPECTED
     MOVE SP-PAUSED TO WS-E1
     MOVE SP-PAUSE-SENT TO WS-E2
     MOVE 0 TO WS-N
     IF WS-T4 > WS-T3 + 10
         MOVE 1 TO WS-N
     END-IF
     MOVE WS-N TO WS-E3
     MOVE 0 TO WS-N
     IF WS-T4 > WS-T3 + 200
         MOVE 1 TO WS-N
     END-IF
     MOVE WS-N TO WS-E4
     MOVE SPACES TO TL-OBSERVED
     STRING "paused " FUNCTION TRIM(WS-E1) " sent " FUNCTION TRIM(WS-E2) " advanced " FUNCTION TRIM(WS-E3)
         " caught-up " FUNCTION TRIM(WS-E4) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Open to Others: pause menu, the open-to-others screen, guests in creative, Open the World.
     CALL "CV-KEY" USING CONVH WS-ALICE WS-KEY
     MOVE ACT-OPEN-TO-OTHERS TO WS-ACTION
     CALL "CV-CLICK" USING CONVH WS-ALICE WS-ACTION WS-ARG WS-FOUND
     MOVE ACT-GUEST-MODE TO WS-ACTION
     CALL "CV-CLICK" USING CONVH WS-ALICE WS-ACTION WS-ARG WS-FOUND
     MOVE ACT-OPEN-WORLD TO WS-ACTION
     CALL "CV-CLICK" USING CONVH WS-ALICE WS-ACTION WS-ARG WS-FOUND
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE SP-PORT TO WS-PORT
     MOVE SP-LISTENER TO WS-E1
     MOVE SM-SCREEN TO WS-E2
     CALL "CV-JOIN" USING CONVH WS-BOBBY WS-PORT
     CALL "PS-UNTIL-PLAY" USING CONVH WS-BOBBY WS-JOINED2
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-BOBBY)
     MOVE PL-MODE TO WS-E3
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE CN-PHASE(CONN-GAME) TO WS-E4
     MOVE "acceptance SPC-4 given a world in a child when the Player opens it to others in creative then the child listens on "
         & "the reported port and a second client joins there as a guest in creative while the host stays in play" TO TL-CASE
     MOVE "port 1 own listener 0 guest joined 1 mode 1 host phase 5" TO TL-EXPECTED
     MOVE 0 TO WS-N
     IF WS-PORT > 0
         MOVE 1 TO WS-N
     END-IF
     MOVE WS-N TO WS-E5
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-JOINED2 TO WS-E2
     STRING "port " FUNCTION TRIM(WS-E5) " own listener " FUNCTION TRIM(WS-E1) " guest joined " FUNCTION TRIM(WS-E2)
         " mode " FUNCTION TRIM(WS-E3) " host phase " FUNCTION TRIM(WS-E4) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Opened: the pause menu no longer pauses (the open-to-others screen came from it; the world is back with Resume).
     MOVE ACT-RESUME TO WS-ACTION
     CALL "CV-CLICK" USING CONVH WS-ALICE WS-ACTION WS-ARG WS-FOUND
     CALL "CV-KEY" USING CONVH WS-ALICE WS-KEY
     CALL "PS-STEPS" USING CONVH WS-FRAMES
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE SM-SCREEN TO WS-E1
     MOVE SP-PAUSED TO WS-E2
     CALL "PS-GAMETIME" USING CONVH WS-ALICE WS-T5 WS-ZERO
     CALL "PS-STEPS" USING CONVH WS-FRAMES
     CALL "PS-GAMETIME" USING CONVH WS-ALICE WS-T6 WS-ZERO
     MOVE "acceptance SPC-5 given the world is opened to others when the pause menu is open then the game does not pause: "
         & "the time moves on" TO TL-CASE
     MOVE "screen 9 paused 0 advanced 1" TO TL-EXPECTED
     MOVE 0 TO WS-N
     IF WS-T5 >= 0 AND WS-T6 > WS-T5 + 10
         MOVE 1 TO WS-N
     END-IF
     MOVE WS-N TO WS-E3
     MOVE SPACES TO TL-OBSERVED
     STRING "screen " FUNCTION TRIM(WS-E1) " paused " FUNCTION TRIM(WS-E2) " advanced " FUNCTION TRIM(WS-E3)
         DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The stop command: the host's chat command ends the world through the client's quit path.
     MOVE ACT-RESUME TO WS-ACTION
     CALL "CV-CLICK" USING CONVH WS-ALICE WS-ACTION WS-ARG WS-FOUND
     MOVE "/stop" TO WS-LINE
     MOVE 5 TO WS-LINE-LENGTH
     CALL "CV-SAY" USING CONVH WS-ALICE WS-LINE WS-LINE-LENGTH
     MOVE SCR-TITLE TO WS-SCREEN
     CALL "CV-UNTIL-SCREEN" USING CONVH WS-ALICE WS-SCREEN WS-REACHED
     CALL "PS-WAIT-GONE" USING WS-PID WS-GONE
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE "acceptance SPC-6 given a world in a child when the host runs the stop command then the client quits to the title "
         & "screen and the child is gone" TO TL-CASE
     MOVE "title 1 hosting 0 child 0 gone 1" TO TL-EXPECTED
     MOVE WS-REACHED TO WS-E1
     MOVE SP-ACTIVE TO WS-E2
     MOVE SP-CHILD TO WS-E3
     MOVE WS-GONE TO WS-E4
     MOVE SPACES TO TL-OBSERVED
     STRING "title " FUNCTION TRIM(WS-E1) " hosting " FUNCTION TRIM(WS-E2) " child " FUNCTION TRIM(WS-E3)
         " gone " FUNCTION TRIM(WS-E4) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-SPPROC-CONTROL.

*> Test helpers (test infrastructure).


 IDENTIFICATION DIVISION.
 PROGRAM-ID. PS-GAMETIME.
*> USING CONVH, index, time out (BINARY-LONG), via (BINARY-LONG; 1: the command goes the way of the screenshot start-up commands, CL-CMD-TEXT
*> through STARTUP-COMMANDS, which needs the world screen; 0: SPP-CONSOLE directly): the world's game time as the hosted world's console answers it: the console command
*> "time query gametime" through the child (SPP-CONSOLE), its reply line captured from standard output (a few frames to arrive); -1
*> when no number came.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-FILE                PIC X(256) VALUE "build/conv-spproc-control/console.txt".
 01 WS-LINE                PIC X(257).
 01 WS-TEXT                PIC X(4096).
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-DIGITS              BINARY-LONG.
 01 WS-VALUE               BINARY-LONG.
 01 WS-ROUND               BINARY-LONG.
 LINKAGE SECTION.
 COPY CONVH.
 COPY CLSTATE.
 01 L-INDEX                BINARY-LONG.
 01 L-TIME                 BINARY-LONG.
 01 L-VIA                  BINARY-LONG.
 PROCEDURE DIVISION USING CONVH L-INDEX L-TIME L-VIA.
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(L-INDEX)
     MOVE LOW-VALUES TO WS-LINE
     MOVE "time query gametime" TO WS-LINE(1:19)
     CALL "PS-CAPTURE-START" USING WS-FILE
     IF L-VIA = 1
         MOVE SPACES TO CL-CMD-TEXT
         MOVE "time query gametime" TO CL-CMD-TEXT
         MOVE 1 TO CL-CMD-AT
     ELSE
         CALL "SPP-CONSOLE" USING CLIENT-STATE WS-LINE
     END-IF
     MOVE -1 TO L-TIME
     PERFORM VARYING WS-ROUND FROM 1 BY 1 UNTIL WS-ROUND > 100 OR L-TIME >= 0
         CALL "PS-STEPS" USING CONVH WS-ONE
         CALL "PS-CAPTURE-STOP" USING WS-FILE WS-TEXT
         CALL "PS-CAPTURE-START" USING WS-FILE
         IF WS-TEXT NOT = SPACES
             PERFORM LAST-NUMBER
         END-IF
     END-PERFORM
     CALL "PS-CAPTURE-STOP" USING WS-FILE WS-TEXT
     GOBACK.

*>   The last run of digits of the captured text.
 LAST-NUMBER.
     MOVE 0 TO WS-DIGITS WS-VALUE
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4096
         IF WS-TEXT(WS-K:1) >= "0" AND WS-TEXT(WS-K:1) <= "9"
             IF WS-DIGITS = 0
                 MOVE 0 TO WS-VALUE
             END-IF
             COMPUTE WS-VALUE = WS-VALUE * 10 + FUNCTION NUMVAL(WS-TEXT(WS-K:1))
             ADD 1 TO WS-DIGITS
         ELSE
             IF WS-DIGITS > 0
                 MOVE WS-VALUE TO L-TIME
             END-IF
             MOVE 0 TO WS-DIGITS
         END-IF
     END-PERFORM.
 END PROGRAM PS-GAMETIME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PS-CAPTURE-START.
*> USING file (PIC X(256)): from now on standard output goes to that file (as SVT-CAPTURE-START of the server tests).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 PS-SAVED-FD            BINARY-LONG EXTERNAL.
 01 WS-NULL                USAGE POINTER VALUE NULL.
 01 WS-STDOUT              BINARY-LONG VALUE 1.
 01 WS-MODE                BINARY-LONG VALUE 420.
 01 WS-FD                  BINARY-LONG.
 01 WS-RC                  BINARY-LONG.
 01 WS-PATH                PIC X(257).
 LINKAGE SECTION.
 01 L-PATH                 PIC X(256).
 PROCEDURE DIVISION USING L-PATH.
     MOVE LOW-VALUES TO WS-PATH
     STRING L-PATH DELIMITED BY SPACE INTO WS-PATH
     CALL STATIC "fflush" USING BY VALUE WS-NULL RETURNING WS-RC
     CALL STATIC "dup" USING BY VALUE WS-STDOUT RETURNING PS-SAVED-FD
     CALL STATIC "creat" USING BY REFERENCE WS-PATH BY VALUE WS-MODE RETURNING WS-FD
     CALL STATIC "dup2" USING BY VALUE WS-FD BY VALUE WS-STDOUT RETURNING WS-RC
     CALL STATIC "close" USING BY VALUE WS-FD RETURNING WS-RC
     MOVE 0 TO RETURN-CODE
     GOBACK.
 END PROGRAM PS-CAPTURE-START.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PS-CAPTURE-STOP.
*> USING file (PIC X(256)), text out (PIC X(4096)): standard output is restored; the text is the file's lines joined by " | ".
 ENVIRONMENT DIVISION.
 INPUT-OUTPUT SECTION.
 FILE-CONTROL.
     SELECT OUT-FILE ASSIGN TO WS-PATH
         ORGANIZATION LINE SEQUENTIAL
         FILE STATUS WS-STATUS.
 DATA DIVISION.
 FILE SECTION.
 FD OUT-FILE.
 01 OUT-LINE               PIC X(1024).
 WORKING-STORAGE SECTION.
 01 PS-SAVED-FD            BINARY-LONG EXTERNAL.
 01 WS-NULL                USAGE POINTER VALUE NULL.
 01 WS-STDOUT              BINARY-LONG VALUE 1.
 01 WS-RC                  BINARY-LONG.
 01 WS-PATH                PIC X(256).
 01 WS-STATUS              PIC XX.
 01 WS-AT                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-PATH                 PIC X(256).
 01 L-TEXT                 PIC X(4096).
 PROCEDURE DIVISION USING L-PATH L-TEXT.
     CALL STATIC "fflush" USING BY VALUE WS-NULL RETURNING WS-RC
     CALL STATIC "dup2" USING BY VALUE PS-SAVED-FD BY VALUE WS-STDOUT RETURNING WS-RC
     CALL STATIC "close" USING BY VALUE PS-SAVED-FD RETURNING WS-RC
     MOVE L-PATH TO WS-PATH
     MOVE SPACES TO L-TEXT
     MOVE 1 TO WS-AT
     OPEN INPUT OUT-FILE
     PERFORM UNTIL WS-STATUS NOT = "00"
         MOVE SPACES TO OUT-LINE
         READ OUT-FILE
         IF WS-STATUS = "00"
             IF WS-AT > 1
                 STRING " | " DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-AT
             END-IF
             STRING FUNCTION TRIM(OUT-LINE TRAILING) DELIMITED BY SIZE INTO L-TEXT
                 WITH POINTER WS-AT
         END-IF
     END-PERFORM
     CLOSE OUT-FILE
     MOVE 0 TO RETURN-CODE
     GOBACK.
 END PROGRAM PS-CAPTURE-STOP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PS-ENSURE-SERVER.
*> The built server program next to this test (<build>/convergence/bin/cobolcraft-server, which the Makefile builds with the
*> whole `tests` goal only): made here when a run of this test alone (runtests --only) has not built it.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-BUILD               PIC X(512).
 01 WS-COMMAND             PIC X(2048).
 PROCEDURE DIVISION.
     MOVE SPACES TO WS-BUILD
     ACCEPT WS-BUILD FROM ENVIRONMENT "COBOLCRAFT_BUILD"
     IF WS-BUILD = SPACES
         MOVE "build" TO WS-BUILD
     END-IF
     MOVE LOW-VALUES TO WS-COMMAND
     STRING "B='" FUNCTION TRIM(WS-BUILD) "'; [ -x $B/convergence/bin/cobolcraft-server ] || { C=0; case $B in */coverage) C=1;; esac; "
         "make -s -C tests/convergence BUILD=$B COVERAGE=$C $B/convergence/bin/cobolcraft-server > /dev/null; }"
         DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     GOBACK.
 END PROGRAM PS-ENSURE-SERVER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PS-STEPS.
*> USING CONVH, count: that many frames, each followed by 20 ms of real time (the child ticks every 50 ms of it).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-US                  BINARY-LONG VALUE 20000.
 01 WS-RC                  BINARY-LONG.
 LINKAGE SECTION.
 COPY CONVH.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING CONVH L-COUNT.
     PERFORM L-COUNT TIMES
         CALL "CV-STEP" USING CONVH
         CALL STATIC "usleep" USING BY VALUE WS-US RETURNING WS-RC
     END-PERFORM
     GOBACK.
 END PROGRAM PS-STEPS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PS-UNTIL-PLAY.
*> USING CONVH, index, joined out: frames of PS-STEPS (at most 3000, about 60 s) until the client is in play with the player
*> loaded, or hosting ended; joined 1 when it is in play.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-I                   BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 COPY CONVH.
 COPY CLSTATE.
 01 L-INDEX                BINARY-LONG.
 01 L-JOINED               BINARY-LONG.
 PROCEDURE DIVISION USING CONVH L-INDEX L-JOINED.
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(L-INDEX)
     MOVE 0 TO L-JOINED PL-LOADED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3000 OR L-JOINED = 1
         CALL "PS-STEPS" USING CONVH WS-ONE
         SET ADDRESS OF CLIENT-STATE TO CV-ADDR(L-INDEX)
         IF CN-PHASE(CONN-GAME) = PH-PLAY AND PL-LOADED = 1
             MOVE 1 TO L-JOINED
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PS-UNTIL-PLAY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PS-KEY-SET.
*> USING CONVH, index, key, kind: CV-QUEUE of a key event and one frame of PS-STEPS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-X                   FLOAT-SHORT VALUE 0.
 01 WS-Y                   FLOAT-SHORT VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 COPY CONVH.
 01 L-INDEX                BINARY-LONG.
 01 L-KEY                  BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 PROCEDURE DIVISION USING CONVH L-INDEX L-KEY L-KIND.
     CALL "CV-QUEUE" USING CONVH L-INDEX L-KIND L-KEY WS-X WS-Y
     CALL "PS-STEPS" USING CONVH WS-ONE
     GOBACK.
 END PROGRAM PS-KEY-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PS-BUTTON-SET.
*> USING CONVH, index, button, kind: a mouse button event at the window centre and one frame of PS-STEPS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-X                   FLOAT-SHORT VALUE 0.
 01 WS-Y                   FLOAT-SHORT VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 COPY CONVH.
 01 L-INDEX                BINARY-LONG.
 01 L-BUTTON               BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 PROCEDURE DIVISION USING CONVH L-INDEX L-BUTTON L-KIND.
     CALL "CV-BUTTON-SET" USING CONVH L-INDEX L-BUTTON L-KIND
     CALL "PS-STEPS" USING CONVH WS-ONE
     GOBACK.
 END PROGRAM PS-BUTTON-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PS-ALIVE.
*> USING pid (BINARY-LONG), alive out: 1 when kill(pid, 0) finds the process.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-RC                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-PID                  BINARY-LONG.
 01 L-ALIVE                BINARY-LONG.
 PROCEDURE DIVISION USING L-PID L-ALIVE.
     CALL STATIC "kill" USING BY VALUE L-PID BY VALUE WS-ZERO RETURNING WS-RC
     MOVE 0 TO L-ALIVE
     IF WS-RC = 0
         MOVE 1 TO L-ALIVE
     END-IF
     GOBACK.
 END PROGRAM PS-ALIVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PS-WAIT-GONE.
*> USING pid (BINARY-LONG), gone out: 1 once the process no longer exists (polled every 100 ms for at most 40 s).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-US                  BINARY-LONG VALUE 100000.
 01 WS-RC                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ALIVE               BINARY-LONG.
 LINKAGE SECTION.
 01 L-PID                  BINARY-LONG.
 01 L-GONE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-PID L-GONE.
     MOVE 1 TO WS-ALIVE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 400 OR WS-ALIVE = 0
         CALL "PS-ALIVE" USING L-PID WS-ALIVE
         IF WS-ALIVE = 1
             CALL STATIC "usleep" USING BY VALUE WS-US RETURNING WS-RC
         END-IF
     END-PERFORM
     MOVE 0 TO L-GONE
     IF WS-ALIVE = 0
         MOVE 1 TO L-GONE
     END-IF
     GOBACK.
 END PROGRAM PS-WAIT-GONE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SP-QUIT-MENU.
*> USING CONVH, index: Escape (the pause menu), Quit World, frames until the title screen.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CCSHIM.
 01 WS-KEY                 BINARY-LONG VALUE CC-KEY-ESCAPE.
 01 WS-ACTION              BINARY-LONG VALUE ACT-QUIT-WORLD.
 01 WS-ARG                 BINARY-LONG VALUE 0.
 01 WS-FOUND               BINARY-LONG.
 01 WS-SCREEN              BINARY-LONG VALUE SCR-TITLE.
 01 WS-REACHED             BINARY-LONG.
 LINKAGE SECTION.
 COPY CONVH.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING CONVH L-INDEX.
     CALL "CV-KEY" USING CONVH L-INDEX WS-KEY
     CALL "CV-CLICK" USING CONVH L-INDEX WS-ACTION WS-ARG WS-FOUND
     CALL "CV-UNTIL-SCREEN" USING CONVH L-INDEX WS-SCREEN WS-REACHED
     MOVE 0 TO CV-HOST
     GOBACK.
 END PROGRAM SP-QUIT-MENU.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. AIM-AT.
*> USING CLIENT-STATE, target x, y, z (FLOAT-LONG): the local player looks from the eye (feet + 1.6)
*> at that point (yaw 0 faces +Z, 90 faces -X; positive pitch looks down).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-H                   FLOAT-LONG.
 01 WS-A                   FLOAT-LONG.
 01 WS-NX                  FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-X L-Y L-Z.
     COMPUTE WS-DX = L-X - PL-X
     COMPUTE WS-DY = L-Y - PL-Y - 1.6
     COMPUTE WS-DZ = L-Z - PL-Z
     COMPUTE WS-NX = 0 - WS-DX
     CALL "ATAN2-DEG" USING WS-NX WS-DZ WS-A
     MOVE WS-A TO PL-YAW
     COMPUTE WS-H = FUNCTION SQRT(WS-DX * WS-DX + WS-DZ * WS-DZ)
     CALL "ATAN2-DEG" USING WS-DY WS-H WS-A
     COMPUTE PL-PITCH = 0 - WS-A
     GOBACK.
 END PROGRAM AIM-AT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ATAN2-DEG.
*> USING y, x, angle out (FLOAT-LONG, degrees, -180 to 180).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-A                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-Y                    FLOAT-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-A                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-Y L-X L-A.
     EVALUATE TRUE
         WHEN L-X > 0
             COMPUTE WS-A = FUNCTION ATAN(L-Y / L-X)
         WHEN L-X < 0 AND L-Y >= 0
             COMPUTE WS-A = FUNCTION ATAN(L-Y / L-X) + FUNCTION PI
         WHEN L-X < 0
             COMPUTE WS-A = FUNCTION ATAN(L-Y / L-X) - FUNCTION PI
         WHEN L-Y > 0
             COMPUTE WS-A = FUNCTION PI / 2
         WHEN L-Y < 0
             COMPUTE WS-A = 0 - FUNCTION PI / 2
         WHEN OTHER
             MOVE 0 TO WS-A
     END-EVALUATE
     COMPUTE L-A = WS-A * 180 / FUNCTION PI
     GOBACK.
 END PROGRAM ATAN2-DEG.
