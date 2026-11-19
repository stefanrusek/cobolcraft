*> Convergence acceptance test of the failures and the loading of a single-player world in a child process (lane spproc,
*> docs/design/singleplayer-process.md): a child killed while the client plays ends hosting with the disconnect screen (the client
*> never hangs, the child is reaped); a child that dies while it starts (a damaged level.dat) does the same; a world the core refuses (data
*> without a level.dat) is reported by the child (@refused) and the client returns to the screen it came from with the refusal
*> shown; a new standard world (the generated packs, CC_GENERATED_DIR) shows the child's loading progress (the @load lines: state,
*> permille and the chunk grid) until the Player is in play, and a new superflat world is made from the preset of the create-world
*> screen in the child. The packs-dependent cases are skipped without the generated packs.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-SPPROC-FAILURE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONVH.
 COPY CLCONST.
 COPY CCSHIM.
 COPY CONTENT.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/conv-spproc-failure".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 25.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-FOLDER              PIC X(80).
 01 WS-FOLDER-LENGTH       BINARY-LONG.
 01 WS-SURVIVAL            BINARY-LONG VALUE 0.
 01 WS-ALICE               BINARY-LONG.
 01 WS-JOINED              BINARY-LONG.
 01 WS-ENDED               BINARY-LONG.
 01 WS-PID                 BINARY-LONG.
 01 WS-ALIVE               BINARY-LONG.
 01 WS-GONE                BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-KILL                BINARY-LONG VALUE 9.
 01 WS-SEEN-STATE          BINARY-LONG.
 01 WS-SEEN-CELLS          BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-DIR-ENV             PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-COMMAND             PIC X(512).
 01 WS-CONSOLE             PIC X(1025).
 01 WS-SCREEN              BINARY-LONG VALUE SCR-CREATE-WORLD.
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
     MOVE "T" TO TL-MODE

*>   The child is killed while the Player plays.
     MOVE "Crash" TO WS-FOLDER
     MOVE 5 TO WS-FOLDER-LENGTH
     CALL "CV-HOST-OPEN" USING CONVH WS-ALICE WS-FOLDER WS-FOLDER-LENGTH WS-SURVIVAL
     CALL "PS-UNTIL-PLAY" USING CONVH WS-ALICE WS-JOINED
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE SP-CHILD-PID TO WS-PID
     CALL STATIC "kill" USING BY VALUE WS-PID BY VALUE WS-KILL RETURNING WS-N
     CALL "PS-UNTIL-HOSTING-ENDS" USING CONVH WS-ALICE WS-ENDED
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     CALL "PS-ALIVE" USING WS-PID WS-ALIVE
     MOVE "acceptance SPF-1 given the Player plays in a child's world when the child is killed then hosting ends, "
         & "the disconnect screen shows the lost connection and the child is reaped" TO TL-CASE
     MOVE "joined 1 ended 1 screen 2 message 1 child 0 alive 0 process 0" TO TL-EXPECTED
     MOVE WS-JOINED TO WS-E1
     MOVE WS-ENDED TO WS-E2
     MOVE SM-SCREEN TO WS-E3
     MOVE 0 TO WS-N
     IF SM-MESSAGE-LENGTH > 0
         MOVE 1 TO WS-N
     END-IF
     MOVE WS-N TO WS-E4
     MOVE SP-CHILD TO WS-E5
     MOVE WS-ALIVE TO WS-E6
     MOVE SP-PROCESS TO WS-E7
     MOVE SPACES TO TL-OBSERVED
     STRING "joined " FUNCTION TRIM(WS-E1) " ended " FUNCTION TRIM(WS-E2) " screen " FUNCTION TRIM(WS-E3)
         " message " FUNCTION TRIM(WS-E4) " child " FUNCTION TRIM(WS-E5) " alive " FUNCTION TRIM(WS-E6)
         " process " FUNCTION TRIM(WS-E7) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The child dies while it starts: a level.dat that is not a world.
     MOVE LOW-VALUES TO WS-COMMAND
     STRING "mkdir -p build/conv-spproc-failure/Alice/saves/Broken && echo broken > build/conv-spproc-failure/Alice/saves/Broken/level.dat"
         DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     MOVE "Broken" TO WS-FOLDER
     MOVE 6 TO WS-FOLDER-LENGTH
     CALL "CV-HOST-OPEN" USING CONVH WS-ALICE WS-FOLDER WS-FOLDER-LENGTH WS-SURVIVAL
     CALL "PS-UNTIL-HOSTING-ENDS" USING CONVH WS-ALICE WS-ENDED
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE "acceptance SPF-2 given a world the child cannot read when the Player opens it then hosting ends with the "
         & "disconnect screen, not a hang" TO TL-CASE
     MOVE "ended 1 screen 2 child 0" TO TL-EXPECTED
     MOVE WS-ENDED TO WS-E1
     MOVE SM-SCREEN TO WS-E2
     MOVE SP-CHILD TO WS-E3
     MOVE SPACES TO TL-OBSERVED
     STRING "ended " FUNCTION TRIM(WS-E1) " screen " FUNCTION TRIM(WS-E2) " child " FUNCTION TRIM(WS-E3)
         DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The core refuses a folder of world data without a level.dat: the client is back on its screen with the refusal.
     MOVE LOW-VALUES TO WS-COMMAND
     STRING "mkdir -p build/conv-spproc-failure/Alice/saves/Refuse/region && : > build/conv-spproc-failure/Alice/saves/Refuse/region/r.0.0.mca"
         DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     MOVE "Refuse" TO WS-FOLDER
     MOVE 6 TO WS-FOLDER-LENGTH
     CALL "CV-HOST-OPEN" USING CONVH WS-ALICE WS-FOLDER WS-FOLDER-LENGTH WS-SURVIVAL
     CALL "PS-UNTIL-HOSTING-ENDS" USING CONVH WS-ALICE WS-ENDED
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE "acceptance SPF-3 given a folder of world data without a level.dat when the Player opens it then the child "
         & "reports the refusal, the client is back on the screen it came from with the refusal and no child is left" TO TL-CASE
     MOVE "ended 1 screen 1 refused 2 child 0" TO TL-EXPECTED
     MOVE WS-ENDED TO WS-E1
     MOVE SM-SCREEN TO WS-E2
     MOVE SP-CREATE-REFUSED TO WS-E3
     MOVE SP-CHILD TO WS-E4
     MOVE SPACES TO TL-OBSERVED
     STRING "ended " FUNCTION TRIM(WS-E1) " screen " FUNCTION TRIM(WS-E2) " refused " FUNCTION TRIM(WS-E3)
         " child " FUNCTION TRIM(WS-E4) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The host is kicked from its own world (a console command): the game connection ends, so hosting ends and the child is told to stop.
     MOVE "Kick" TO WS-FOLDER
     MOVE 4 TO WS-FOLDER-LENGTH
     CALL "CV-HOST-OPEN" USING CONVH WS-ALICE WS-FOLDER WS-FOLDER-LENGTH WS-SURVIVAL
     CALL "PS-UNTIL-PLAY" USING CONVH WS-ALICE WS-JOINED
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE SP-CHILD-PID TO WS-PID
     MOVE LOW-VALUES TO WS-CONSOLE
     MOVE "kick Alice" TO WS-CONSOLE(1:10)
     CALL "SPP-CONSOLE" USING CLIENT-STATE WS-CONSOLE
     CALL "PS-UNTIL-HOSTING-ENDS" USING CONVH WS-ALICE WS-ENDED
     CALL "PS-WAIT-GONE" USING WS-PID WS-GONE
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE "acceptance SPF-6 given the host is kicked from the child's world when the game connection ends then hosting "
         & "ends with the disconnect screen and the child, told to stop, is gone" TO TL-CASE
     MOVE "joined 1 ended 1 screen 2 child 0 gone 1" TO TL-EXPECTED
     MOVE WS-JOINED TO WS-E1
     MOVE WS-ENDED TO WS-E2
     MOVE SM-SCREEN TO WS-E3
     MOVE SP-CHILD TO WS-E4
     MOVE WS-GONE TO WS-E5
     MOVE SPACES TO TL-OBSERVED
     STRING "joined " FUNCTION TRIM(WS-E1) " ended " FUNCTION TRIM(WS-E2) " screen " FUNCTION TRIM(WS-E3)
         " child " FUNCTION TRIM(WS-E4) " gone " FUNCTION TRIM(WS-E5) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A standard world without usable packs is refused by the child as well (the create-world screen checks first, SP-OPEN does not).
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE SPACES TO CL-GENERATED-DIR
     MOVE "build/conv-spproc-failure/no-packs" TO CL-GENERATED-DIR
     MOVE 33 TO CL-GENERATED-DIR-LENGTH
     MOVE CT-TYPE-STANDARD TO SP-CREATE-TYPE
     MOVE "NoPacks" TO WS-FOLDER
     MOVE 7 TO WS-FOLDER-LENGTH
     CALL "CV-HOST-OPEN" USING CONVH WS-ALICE WS-FOLDER WS-FOLDER-LENGTH WS-SURVIVAL
     CALL "PS-UNTIL-HOSTING-ENDS" USING CONVH WS-ALICE WS-ENDED
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE "acceptance SPF-7 given no usable generated packs when a standard world is opened then the child reports "
         & "the packs refusal and the client shows it on the screen it came from" TO TL-CASE
     MOVE "ended 1 screen 1 refused 1" TO TL-EXPECTED
     MOVE WS-ENDED TO WS-E1
     MOVE SM-SCREEN TO WS-E2
     MOVE SP-CREATE-REFUSED TO WS-E3
     MOVE SPACES TO TL-OBSERVED
     STRING "ended " FUNCTION TRIM(WS-E1) " screen " FUNCTION TRIM(WS-E2) " refused " FUNCTION TRIM(WS-E3)
         DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE CT-TYPE-COBOLCRAFT TO SP-CREATE-TYPE

*>   The server program in the hosted role without its handshake (end of input) is fatal, exit status 1.
     CALL "PS-NO-HANDSHAKE"
     MOVE "acceptance SPF-8 given the hosted server program when its standard input ends before the handshake then it "
         & "ends with a fatal message and exit status 1" TO TL-CASE
     MOVE "fatal 1" TO TL-EXPECTED
     MOVE 0 TO WS-N
     IF RETURN-CODE = 0
         MOVE 1 TO WS-N
     END-IF
     MOVE WS-N TO WS-E1
     MOVE SPACES TO TL-OBSERVED
     STRING "fatal " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The generated packs: a standard world shows the child's progress; a superflat world takes the create-world preset.
     MOVE SPACES TO WS-DIR-ENV
     ACCEPT WS-DIR-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-DIR-ENV = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-DIR-ENV
     END-IF
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-DIR-ENV TRAILING) "/vanilla-data/pack.mcmeta" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE NOT = 0
         MOVE "N" TO TL-MODE
         MOVE "acceptance SPF-4 spproc: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE SPACES TO CL-GENERATED-DIR
     MOVE WS-DIR-ENV TO CL-GENERATED-DIR
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-DIR-ENV TRAILING)) TO CL-GENERATED-DIR-LENGTH
     CALL "PACKS-RELOAD" USING CLIENT-STATE
     CALL "SCREEN-OPEN" USING CLIENT-STATE WS-SCREEN
     MOVE CT-TYPE-STANDARD TO SP-CREATE-TYPE
     MOVE "Standard" TO WS-FOLDER
     MOVE 8 TO WS-FOLDER-LENGTH
     CALL "CV-HOST-OPEN" USING CONVH WS-ALICE WS-FOLDER WS-FOLDER-LENGTH WS-SURVIVAL
     CALL "PS-UNTIL-PLAY-TRACK" USING CONVH WS-ALICE WS-JOINED WS-SEEN-STATE WS-SEEN-CELLS WS-MAX
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE "acceptance SPF-4 given a new standard world in a child when the Player opens it then the loading screen shows "
         & "the child's progress (state, grid, permille) until the Player is in play over TCP" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "joined 1 state 1 cells 1 permille 1 memory 0" TO TL-EXPECTED
     MOVE WS-JOINED TO WS-E1
     MOVE WS-SEEN-STATE TO WS-E2
     MOVE WS-SEEN-CELLS TO WS-E3
     MOVE 0 TO WS-N
     IF WS-MAX > 0
         MOVE 1 TO WS-N
     END-IF
     MOVE WS-N TO WS-E4
     MOVE CN-MEMORY(CONN-GAME) TO WS-E5
     MOVE SPACES TO TL-OBSERVED
     STRING "joined " FUNCTION TRIM(WS-E1) " state " FUNCTION TRIM(WS-E2) " cells " FUNCTION TRIM(WS-E3)
         " permille " FUNCTION TRIM(WS-E4) " memory " FUNCTION TRIM(WS-E5) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "SP-QUIT-MENU" USING CONVH WS-ALICE

     CALL "SCREEN-OPEN" USING CLIENT-STATE WS-SCREEN
     MOVE CL-TYPE-SUPERFLAT TO SP-CREATE-TYPE
     MOVE "Flat" TO WS-FOLDER
     MOVE 4 TO WS-FOLDER-LENGTH
     CALL "CV-HOST-OPEN" USING CONVH WS-ALICE WS-FOLDER WS-FOLDER-LENGTH WS-SURVIVAL
     CALL "PS-UNTIL-PLAY-TRACK" USING CONVH WS-ALICE WS-JOINED WS-SEEN-STATE WS-SEEN-CELLS WS-MAX
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE "acceptance SPF-5 given a new superflat world in a child when the Player opens it then they are in play over TCP" TO TL-CASE
     MOVE "joined 1 process 1" TO TL-EXPECTED
     MOVE WS-JOINED TO WS-E1
     MOVE SP-PROCESS TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING "joined " FUNCTION TRIM(WS-E1) " process " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "SP-QUIT-MENU" USING CONVH WS-ALICE
     STOP RUN.
 END PROGRAM ACC-SPPROC-FAILURE.

*> Test helpers (test infrastructure).



 IDENTIFICATION DIVISION.
 PROGRAM-ID. PS-UNTIL-PLAY-TRACK.
*> USING CONVH, index, joined out, seen-state out, seen-cells out, max permille out (BINARY-LONG): as PS-UNTIL-PLAY (at most 9000
*> frames) and, over the frames, whether the loading progress of the child showed a state above 0 (SP-LOAD-STATE), a non-empty grid
*> (SM-LOAD-CELLS holds a cell above 0) and the highest SP-LOAD-PERMILLE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 COPY CONVH.
 COPY CLSTATE.
 01 L-INDEX                BINARY-LONG.
 01 L-JOINED               BINARY-LONG.
 01 L-SEEN-STATE           BINARY-LONG.
 01 L-SEEN-CELLS           BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 PROCEDURE DIVISION USING CONVH L-INDEX L-JOINED L-SEEN-STATE L-SEEN-CELLS L-MAX.
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(L-INDEX)
     MOVE 0 TO L-JOINED PL-LOADED L-SEEN-STATE L-SEEN-CELLS L-MAX
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 9000 OR L-JOINED = 1
         CALL "PS-STEPS" USING CONVH WS-ONE
         SET ADDRESS OF CLIENT-STATE TO CV-ADDR(L-INDEX)
         IF SP-PROCESS = 1 AND SP-LOAD-STATE > 0 AND CN-PHASE(CONN-GAME) NOT = PH-PLAY
             MOVE 1 TO L-SEEN-STATE
             IF SP-LOAD-PERMILLE > L-MAX
                 MOVE SP-LOAD-PERMILLE TO L-MAX
             END-IF
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 1225 OR L-SEEN-CELLS = 1
                 IF SM-LOAD-CELLS(WS-K:1) NOT = LOW-VALUE
                     MOVE 1 TO L-SEEN-CELLS
                 END-IF
             END-PERFORM
         END-IF
         IF CN-PHASE(CONN-GAME) = PH-PLAY AND PL-LOADED = 1
             MOVE 1 TO L-JOINED
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PS-UNTIL-PLAY-TRACK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PS-UNTIL-HOSTING-ENDS.
*> USING CONVH, index, ended out: PS-STEPS frames (at most 1000, about 20 s) until the client no longer hosts (SP-ACTIVE 0).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 COPY CONVH.
 COPY CLSTATE.
 01 L-INDEX                BINARY-LONG.
 01 L-ENDED                BINARY-LONG.
 PROCEDURE DIVISION USING CONVH L-INDEX L-ENDED.
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(L-INDEX)
     MOVE 0 TO L-ENDED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 1000 OR L-ENDED = 1
         CALL "PS-STEPS" USING CONVH WS-ONE
         SET ADDRESS OF CLIENT-STATE TO CV-ADDR(L-INDEX)
         IF SP-ACTIVE = 0
             MOVE 1 TO L-ENDED
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PS-UNTIL-HOSTING-ENDS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PS-NO-HANDSHAKE.
*> Runs <build>/convergence/bin/cobolcraft-server --hosted with empty standard input; RETURN-CODE is 0 when it ended with exit status 1 and
*> the fatal text "the handshake did not arrive" on its standard error, else not 0.
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
     STRING "'" FUNCTION TRIM(WS-BUILD) "/convergence/bin/cobolcraft-server' --hosted < /dev/null > /dev/null 2> build/conv-spproc-failure/err.txt;"
         " [ $? -eq 1 ] && grep -q 'the handshake did not arrive' build/conv-spproc-failure/err.txt"
         DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     GOBACK.
 END PROGRAM PS-NO-HANDSHAKE.

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
