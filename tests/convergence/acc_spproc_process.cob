*> Convergence acceptance test of the single-player world in a child process (lane spproc, docs/design/singleplayer-process.md): with
*> SP-PROCESS-PREF 1 (CC_SP_PROCESS=1) SP-OPEN starts the built cobolcraft-server --hosted next to this program (../bin) instead of
*> opening the core in the client: the Player's client joins it over loopback TCP (no memory connection, offline login as the
*> Player's name), walks, places a block, quits to the title screen (the child saves the world and ends, nothing is left running)
*> and opens the saved world again in a new child, where the block is. A client that dies without a quit leaves a child that saves
*> and ends by itself (end of its input): the world holds the block that was placed before the kill. A server program that cannot
*> be found (CC_SERVER_BIN) opens the world in this process as before. The child ticks in real time, so the frames here sleep.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-SPPROC-PROCESS.
 ENVIRONMENT DIVISION.
 INPUT-OUTPUT SECTION.
 FILE-CONTROL.
     SELECT PID-FILE ASSIGN TO "build/conv-spproc/orphan.pid" ORGANIZATION LINE SEQUENTIAL.
 DATA DIVISION.
 FILE SECTION.
 FD PID-FILE.
 01 PID-RECORD             PIC X(32).
 WORKING-STORAGE SECTION.
 COPY CONVH.
 COPY CLCONST.
 COPY CCSHIM.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/conv-spproc".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 17.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-FOLDER              PIC X(80) VALUE "Proc".
 01 WS-FOLDER-LENGTH       BINARY-LONG VALUE 4.
 01 WS-SURVIVAL            BINARY-LONG VALUE 0.
 01 WS-ALICE               BINARY-LONG.
 01 WS-JOINED              BINARY-LONG.
 01 WS-PID                 BINARY-LONG.
 01 WS-ALIVE               BINARY-LONG.
 01 WS-GONE                BINARY-LONG.
 01 WS-KEY                 BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-BUTTON              BINARY-LONG.
 01 WS-TX                  FLOAT-LONG.
 01 WS-TY                  FLOAT-LONG.
 01 WS-TZ                  FLOAT-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-Z0                  FLOAT-LONG.
 01 WS-DIST                FLOAT-LONG.
 01 WS-CELL-X              BINARY-LONG VALUE 6.
 01 WS-CELL-Y              BINARY-LONG VALUE 54.
 01 WS-CELL-Z              BINARY-LONG VALUE 8.
 01 WS-STATE               BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-LIGHT               BINARY-LONG.
 01 WS-BEFORE              BINARY-LONG.
 01 WS-PLACED              BINARY-LONG.
 01 WS-X10                 BINARY-LONG.
 01 WS-Y10                 BINARY-LONG.
 01 WS-Z10                 BINARY-LONG.
 01 WS-SCREEN-AT-START     BINARY-LONG.
 01 WS-FORKED              BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-COMMAND             PIC X(256).
 01 WS-ENV-NAME            PIC X(16) VALUE Z"CC_SERVER_BIN".
 01 WS-ENV-VALUE           PIC X(40) VALUE Z"/nonexistent/cobolcraft-server".
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-E4                  PIC -(9)9.
 01 WS-E5                  PIC -(9)9.
 01 WS-E6                  PIC -(9)9.
 01 WS-E7                  PIC -(9)9.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION.
     CALL "PS-ENSURE-SERVER"
     CALL "CV-INIT" USING CONVH WS-DIR WS-DIR-LENGTH
     CALL "CV-CLIENT-ADD" USING CONVH WS-NAME WS-NAME-LENGTH WS-ALICE
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE 1 TO SP-PROCESS-PREF
     CALL "CV-HOST-OPEN" USING CONVH WS-ALICE WS-FOLDER WS-FOLDER-LENGTH WS-SURVIVAL
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE 0 TO WS-N
     IF SP-CHILD > 0
         MOVE 1 TO WS-N
     END-IF
     MOVE SP-PROCESS TO WS-E1
     MOVE SP-ACTIVE TO WS-E2
     MOVE WS-N TO WS-E3
     MOVE SP-PROC-STATE TO WS-E4
     MOVE SM-SCREEN TO WS-E5
     MOVE CN-MEMORY(CONN-GAME) TO WS-E6
     MOVE SM-LOAD-SHOWN TO WS-E7
     MOVE "acceptance SPP-1 given the process mode when the Player opens a new world then the server program "
         & "is started as a child, the connecting screen shows the loading screen at once and no core runs in the client" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "process 1 hosting 1 child 1 state 1 screen 4 shown 1 memory 0" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING "process " FUNCTION TRIM(WS-E1) " hosting " FUNCTION TRIM(WS-E2) " child " FUNCTION TRIM(WS-E3)
         " state " FUNCTION TRIM(WS-E4) " screen " FUNCTION TRIM(WS-E5) " shown " FUNCTION TRIM(WS-E7)
         " memory " FUNCTION TRIM(WS-E6) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "PS-UNTIL-PLAY" USING CONVH WS-ALICE WS-JOINED
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE SP-CHILD-PID TO WS-PID
     CALL "PS-ALIVE" USING WS-PID WS-ALIVE
     PERFORM POSITION-TEN
     MOVE WS-JOINED TO WS-E1
     MOVE CN-MEMORY(CONN-GAME) TO WS-E2
     MOVE WS-ALIVE TO WS-E3
     MOVE SP-PROC-STATE TO WS-E4
     MOVE "acceptance SPP-2 given the child is ready when the client joins then it is in play over loopback "
         & "TCP as the Player at the world spawn, the child process running" TO TL-CASE
     MOVE "joined 1 memory 0 host 127.0.0.1 alive 1 state 2 at 45 540 85" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-X10 TO WS-E5
     MOVE WS-Y10 TO WS-E6
     MOVE WS-Z10 TO WS-E7
     STRING "joined " FUNCTION TRIM(WS-E1) " memory " FUNCTION TRIM(WS-E2) " host "
         CN-HOST(CONN-GAME)(1:CN-HOST-LENGTH(CONN-GAME)) " alive " FUNCTION TRIM(WS-E3) " state "
         FUNCTION TRIM(WS-E4) " at " FUNCTION TRIM(WS-E5) " " FUNCTION TRIM(WS-E6) " " FUNCTION TRIM(WS-E7)
         DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Walking: D (facing east) moves the Player at least two blocks.
     MOVE PL-X TO WS-X0
     MOVE PL-Z TO WS-Z0
     MOVE CC-KEY-D TO WS-KEY
     MOVE CC-EV-KEY-DOWN TO WS-KIND
     CALL "PS-KEY-SET" USING CONVH WS-ALICE WS-KEY WS-KIND
     MOVE 20 TO WS-N
     CALL "PS-STEPS" USING CONVH WS-N
     MOVE CC-EV-KEY-UP TO WS-KIND
     CALL "PS-KEY-SET" USING CONVH WS-ALICE WS-KEY WS-KIND
     MOVE 5 TO WS-N
     CALL "PS-STEPS" USING CONVH WS-N
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     COMPUTE WS-DIST = FUNCTION SQRT((PL-X - WS-X0) ** 2 + (PL-Z - WS-Z0) ** 2)
     MOVE 0 TO WS-N
     IF WS-DIST >= 2
         MOVE 1 TO WS-N
     END-IF
     MOVE "acceptance SPP-3 given the Player is in play in the child's world when they hold D then they walk "
         & "at least two blocks and stay connected" TO TL-CASE
     MOVE "moved 1 phase 5" TO TL-EXPECTED
     MOVE WS-N TO WS-E1
     MOVE CN-PHASE(CONN-GAME) TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING "moved " FUNCTION TRIM(WS-E1) " phase " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A block placed on the turf top (6, 53, 8) shows in the replica once the child has answered over TCP.
     PERFORM PLACE-BLOCK
     MOVE 0 TO WS-N
     IF WS-PLACED NOT = WS-BEFORE
         MOVE 1 TO WS-N
     END-IF
     MOVE "acceptance SPP-4 given the Player is in the child's world when they place greystone on the turf then "
         & "the cell changes in their replica (the child confirmed it over TCP)" TO TL-CASE
     MOVE "changed 1" TO TL-EXPECTED
     MOVE WS-N TO WS-E1
     MOVE SPACES TO TL-OBSERVED
     STRING "changed " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Quit world: the child saves and ends before the title screen shows, and nothing is left.
     CALL "SP-QUIT-MENU" USING CONVH WS-ALICE
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     CALL "PS-ALIVE" USING WS-PID WS-ALIVE
     MOVE "acceptance SPP-5 given the Player quits the world when the child has saved then the title screen "
         & "shows, hosting is over, the game connection is closed and the child process is gone" TO TL-CASE
     MOVE "screen 1 hosting 0 process 0 child 0 phase 0 alive 0" TO TL-EXPECTED
     MOVE SM-SCREEN TO WS-E1
     MOVE SP-ACTIVE TO WS-E2
     MOVE SP-PROCESS TO WS-E3
     MOVE SP-CHILD TO WS-E4
     MOVE CN-PHASE(CONN-GAME) TO WS-E5
     MOVE WS-ALIVE TO WS-E6
     MOVE SPACES TO TL-OBSERVED
     STRING "screen " FUNCTION TRIM(WS-E1) " hosting " FUNCTION TRIM(WS-E2) " process " FUNCTION TRIM(WS-E3)
         " child " FUNCTION TRIM(WS-E4) " phase " FUNCTION TRIM(WS-E5) " alive " FUNCTION TRIM(WS-E6)
         DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Opened again from the saved folder: a new child, the block is there.
     CALL "CV-HOST-OPEN" USING CONVH WS-ALICE WS-FOLDER WS-FOLDER-LENGTH WS-SURVIVAL
     CALL "PS-UNTIL-PLAY" USING CONVH WS-ALICE WS-JOINED
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     CALL "WORLD-CELL" USING CLIENT-STATE WS-CELL-X WS-CELL-Y WS-CELL-Z WS-STATE WS-SKY WS-LIGHT
     MOVE "acceptance SPP-6 given the world was saved by the child when it is opened again in a new child "
         & "then the placed block is there" TO TL-CASE
     MOVE "joined 1 same 1" TO TL-EXPECTED
     MOVE WS-JOINED TO WS-E1
     MOVE 0 TO WS-N
     IF WS-STATE = WS-PLACED
         MOVE 1 TO WS-N
     END-IF
     MOVE WS-N TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING "joined " FUNCTION TRIM(WS-E1) " same " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "SP-QUIT-MENU" USING CONVH WS-ALICE

*>   A client that dies without quitting: its child sees end of input, saves and ends. The forked copy of this program is the
*>   client that places a block in a new world and kills itself.
     MOVE "Orphan" TO WS-FOLDER
     MOVE 6 TO WS-FOLDER-LENGTH
     CALL STATIC "fork" RETURNING WS-FORKED
     IF WS-FORKED = 0
         CALL "CV-HOST-OPEN" USING CONVH WS-ALICE WS-FOLDER WS-FOLDER-LENGTH WS-SURVIVAL
         CALL "PS-UNTIL-PLAY" USING CONVH WS-ALICE WS-JOINED
         SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
         PERFORM PLACE-BLOCK
         MOVE SP-CHILD-PID TO WS-E1
         MOVE LOW-VALUES TO WS-COMMAND
         STRING "echo " FUNCTION TRIM(WS-E1) " > build/conv-spproc/orphan.pid" DELIMITED BY SIZE INTO WS-COMMAND
         CALL "SYSTEM" USING WS-COMMAND
         CALL STATIC "getpid" RETURNING WS-N
         CALL STATIC "kill" USING BY VALUE WS-N BY VALUE 9
         STOP RUN
     END-IF
     CALL STATIC "waitpid" USING BY VALUE WS-FORKED BY REFERENCE WS-STATUS BY VALUE 0
     OPEN INPUT PID-FILE
     READ PID-FILE
     CLOSE PID-FILE
     COMPUTE WS-PID = FUNCTION NUMVAL(PID-RECORD)
     CALL "PS-WAIT-GONE" USING WS-PID WS-GONE
     MOVE "acceptance SPP-7 given the client was killed without a quit when its end of input reaches the child "
         & "then the child saves the world and ends by itself" TO TL-CASE
     MOVE "client killed 1 child gone 1" TO TL-EXPECTED
     MOVE 0 TO WS-N
     IF WS-STATUS NOT = 0
         MOVE 1 TO WS-N
     END-IF
     MOVE WS-N TO WS-E1
     MOVE WS-GONE TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING "client killed " FUNCTION TRIM(WS-E1) " child gone " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     CALL "CV-HOST-OPEN" USING CONVH WS-ALICE WS-FOLDER WS-FOLDER-LENGTH WS-SURVIVAL
     CALL "PS-UNTIL-PLAY" USING CONVH WS-ALICE WS-JOINED
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     CALL "WORLD-CELL" USING CLIENT-STATE WS-CELL-X WS-CELL-Y WS-CELL-Z WS-STATE WS-SKY WS-LIGHT
     MOVE "acceptance SPP-8 given the orphaned child saved the world when it is opened again then the block "
         & "placed before the kill is there" TO TL-CASE
     MOVE "joined 1 same 1" TO TL-EXPECTED
     MOVE WS-JOINED TO WS-E1
     MOVE 0 TO WS-N
     IF WS-STATE = WS-PLACED
         MOVE 1 TO WS-N
     END-IF
     MOVE WS-N TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING "joined " FUNCTION TRIM(WS-E1) " same " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "SP-QUIT-MENU" USING CONVH WS-ALICE

*>   A server program that cannot be found: the world opens in this process (memory connection), as before.
     CALL STATIC "setenv" USING WS-ENV-NAME WS-ENV-VALUE BY VALUE WS-ONE
     MOVE "Fallback" TO WS-FOLDER
     MOVE 8 TO WS-FOLDER-LENGTH
     CALL "CV-HOST-OPEN" USING CONVH WS-ALICE WS-FOLDER WS-FOLDER-LENGTH WS-SURVIVAL
     CALL "CV-UNTIL-PLAY" USING CONVH WS-ALICE WS-JOINED
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE "acceptance SPP-9 given no server program is found when the Player opens a world then it is hosted "
         & "in the client over a memory connection" TO TL-CASE
     MOVE "joined 1 process 0 hosting 1 memory 1" TO TL-EXPECTED
     MOVE WS-JOINED TO WS-E1
     MOVE SP-PROCESS TO WS-E2
     MOVE SP-ACTIVE TO WS-E3
     MOVE CN-MEMORY(CONN-GAME) TO WS-E4
     MOVE SPACES TO TL-OBSERVED
     STRING "joined " FUNCTION TRIM(WS-E1) " process " FUNCTION TRIM(WS-E2) " hosting " FUNCTION TRIM(WS-E3)
         " memory " FUNCTION TRIM(WS-E4) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "SP-QUIT-MENU" USING CONVH WS-ALICE
     STOP RUN.

*>   The Player's position in tenths of a block.
 POSITION-TEN.
     COMPUTE WS-X10 ROUNDED = PL-X * 10
     COMPUTE WS-Y10 ROUNDED = PL-Y * 10
     COMPUTE WS-Z10 ROUNDED = PL-Z * 10.

*>   Alice places greystone (slot 0) on the turf top (6, 53, 8), standing at the spawn facing it, and waits until the cell
*>   (6, 54, 8) of her replica changed (the child's block update): WS-BEFORE and WS-PLACED are its states.
 PLACE-BLOCK.
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     CALL "WORLD-CELL" USING CLIENT-STATE WS-CELL-X WS-CELL-Y WS-CELL-Z WS-BEFORE WS-SKY WS-LIGHT
     MOVE 6.5 TO WS-TX
     MOVE 53.95 TO WS-TY
     MOVE 8.5 TO WS-TZ
     CALL "AIM-AT" USING CLIENT-STATE WS-TX WS-TY WS-TZ
     MOVE CC-BUTTON-RIGHT TO WS-BUTTON
     MOVE CC-EV-BUTTON-DOWN TO WS-KIND
     CALL "PS-BUTTON-SET" USING CONVH WS-ALICE WS-BUTTON WS-KIND
     MOVE CC-EV-BUTTON-UP TO WS-KIND
     CALL "PS-BUTTON-SET" USING CONVH WS-ALICE WS-BUTTON WS-KIND
     MOVE WS-BEFORE TO WS-PLACED
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > 250 OR WS-PLACED NOT = WS-BEFORE
         CALL "PS-STEPS" USING CONVH WS-ONE
         SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
         CALL "WORLD-CELL" USING CLIENT-STATE WS-CELL-X WS-CELL-Y WS-CELL-Z WS-PLACED WS-SKY WS-LIGHT
     END-PERFORM.
 END PROGRAM ACC-SPPROC-PROCESS.

*> Test helpers (test infrastructure).

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
