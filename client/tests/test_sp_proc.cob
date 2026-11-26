*> Implementation test of client/src/sp-proc.cob (the single-player child process, docs/design/singleplayer-process.md): the lines of the
*> child's output are understood (@load fills the loading progress and decodes the grid letters, @opened gives the port, @stop-requested
*> asks for the quit, an unknown control line is ignored, a console line is displayed), output arrives in pieces and a line without its
*> newline is kept until it is complete, the pause holds on the pause menu and the open-to-others screen of a world not opened to
*> others only, and the server program is found by $CC_SERVER_BIN alone when it is set. A real child (echo, printf, cat) stands in
*> for the server program.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SP-PROC.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY COREAPI.
 COPY TESTLIB.
 01 WS-LINE                PIC X(1400).
 01 WS-GRID                PIC X(1225).
 01 WS-PATH                PIC X(1100).
 01 WS-SHORT               PIC X(7).
 01 WS-FOUND               BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-RC                  BINARY-LONG.
 01 WS-WAIT                BINARY-LONG.
 01 WS-CONSOLE             PIC X(257).
 01 WS-EMPTY               PIC X(257).
 01 WS-ENV-NAME            PIC X(16) VALUE Z"CC_SERVER_BIN".
 01 WS-ENV-PROCESS         PIC X(16) VALUE Z"CC_SP_PROCESS".
 01 WS-ENV-ONE             PIC X(4) VALUE Z"1".
 01 WS-ENV-SH              PIC X(16) VALUE Z"/bin/sh".
 01 WS-ENV-BAD             PIC X(40) VALUE Z"/nonexistent/cobolcraft-server".
 01 WS-EXE-ECHO            PIC X(16) VALUE Z"/bin/echo".
 01 WS-EXE-PRINTF          PIC X(24) VALUE Z"/usr/bin/printf".
 01 WS-EXE-CAT             PIC X(16) VALUE Z"/bin/cat".
 01 WS-ARGS-ECHO           PIC X(24) VALUE Z"@opened 4242".
 01 WS-ARGS-PRINTF         PIC X(24) VALUE Z"@opened\04099".
 01 WS-ARGS-NONE           PIC X(4) VALUE LOW-VALUES.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-E4                  PIC -(9)9.
 01 WS-E5                  PIC -(9)9.
 01 WS-E6                  PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     MOVE "T" TO TL-MODE
     MOVE 1 TO SP-PROCESS SP-PROC-STATE
     MOVE 0 TO SP-CHILD

*>   @load: the progress fields and the grid (letters A to K are the cell codes 0 to 10).
     MOVE ALL "A" TO WS-GRID
     MOVE "K" TO WS-GRID(1:1)
     MOVE "B" TO WS-GRID(2:1)
     MOVE SPACES TO WS-LINE
     STRING "@load 2 12 49 253 3 -4 " WS-GRID DELIMITED BY SIZE INTO WS-LINE
     MOVE 1248 TO SP-LINE-LENGTH
     MOVE WS-LINE(1:1248) TO SP-LINE(1:1248)
     CALL "SPP-LINE" USING CLIENT-STATE
     MOVE SP-LOAD-STATE TO WS-E1
     MOVE SP-LOAD-READY TO WS-E2
     MOVE SP-LOAD-TOTAL TO WS-E3
     MOVE SP-LOAD-PERMILLE TO WS-E4
     MOVE SP-LOAD-FX TO WS-E5
     MOVE SP-LOAD-FZ TO WS-E6
     MOVE "sp proc a @load line sets the loading progress: state, ready, total, permille and the focus chunk" TO TL-CASE
     MOVE "2 12 49 253 3 -4" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) " " FUNCTION TRIM(WS-E4) " "
         FUNCTION TRIM(WS-E5) " " FUNCTION TRIM(WS-E6) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "sp proc the grid letters of a @load line become the cell codes of SM-LOAD-CELLS" TO TL-CASE
     MOVE "10 1 0 0" TO TL-EXPECTED
     COMPUTE WS-RC = FUNCTION ORD(SM-LOAD-CELLS(1:1)) - 1
     MOVE WS-RC TO WS-E1
     COMPUTE WS-RC = FUNCTION ORD(SM-LOAD-CELLS(2:1)) - 1
     MOVE WS-RC TO WS-E2
     COMPUTE WS-RC = FUNCTION ORD(SM-LOAD-CELLS(3:1)) - 1
     MOVE WS-RC TO WS-E3
     COMPUTE WS-RC = FUNCTION ORD(SM-LOAD-CELLS(1225:1)) - 1
     MOVE WS-RC TO WS-E4
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) " " FUNCTION TRIM(WS-E4)
         DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   @opened, @stop-requested, an unknown control line and a console line.
     MOVE "@opened 4242" TO SP-LINE
     MOVE 12 TO SP-LINE-LENGTH
     CALL "SPP-LINE" USING CLIENT-STATE
     MOVE SP-PORT TO WS-E1
     MOVE "@stop-requested" TO SP-LINE
     MOVE 15 TO SP-LINE-LENGTH
     CALL "SPP-LINE" USING CLIENT-STATE
     MOVE SP-STOP-ASKED TO WS-E2
     MOVE "@mystery 7" TO SP-LINE
     MOVE 10 TO SP-LINE-LENGTH
     CALL "SPP-LINE" USING CLIENT-STATE
     MOVE "Alice joined the game" TO SP-LINE
     MOVE 21 TO SP-LINE-LENGTH
     CALL "SPP-LINE" USING CLIENT-STATE
     MOVE SP-PORT TO WS-E3
     MOVE "sp proc @opened gives the port, @stop-requested asks for the quit, an unknown control line and a console line change nothing" TO TL-CASE
     MOVE "port 4242 asked 1 port 4242" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING "port " FUNCTION TRIM(WS-E1) " asked " FUNCTION TRIM(WS-E2) " port " FUNCTION TRIM(WS-E3)
         DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Output in pieces: a whole line from echo, then a line without newline from printf stays.
     MOVE 0 TO SP-PORT SP-LINE-LENGTH
     CALL STATIC "cc_wk_proc_spawn" USING BY REFERENCE WS-EXE-ECHO BY REFERENCE WS-ARGS-ECHO BY REFERENCE WS-SLOT
         RETURNING WS-RC
     MOVE WS-SLOT TO SP-CHILD
     CALL STATIC "cc_wk_proc_wait" USING BY VALUE SP-CHILD BY VALUE 5000 BY REFERENCE WS-STATUS RETURNING WS-RC
     CALL "SPP-READ" USING CLIENT-STATE
     MOVE SP-PORT TO WS-E1
     MOVE SP-LINE-LENGTH TO WS-E2
     CALL STATIC "cc_wk_proc_stop" USING BY VALUE SP-CHILD RETURNING WS-RC
     CALL STATIC "cc_wk_proc_spawn" USING BY REFERENCE WS-EXE-PRINTF BY REFERENCE WS-ARGS-PRINTF BY REFERENCE WS-SLOT
         RETURNING WS-RC
     MOVE WS-SLOT TO SP-CHILD
     MOVE 0 TO SP-PORT
     CALL STATIC "cc_wk_proc_wait" USING BY VALUE SP-CHILD BY VALUE 5000 BY REFERENCE WS-STATUS RETURNING WS-RC
     CALL "SPP-READ" USING CLIENT-STATE
     MOVE SP-PORT TO WS-E3
     MOVE SP-LINE-LENGTH TO WS-E4
     CALL STATIC "cc_wk_proc_stop" USING BY VALUE SP-CHILD RETURNING WS-RC
     MOVE 0 TO SP-CHILD SP-LINE-LENGTH
     MOVE "sp proc SPP-READ cuts the child's output into lines and keeps a line that has no newline yet" TO TL-CASE
     MOVE "echo port 4242 left 0 printf port 0 left 10" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING "echo port " FUNCTION TRIM(WS-E1) " left " FUNCTION TRIM(WS-E2) " printf port " FUNCTION TRIM(WS-E3)
         " left " FUNCTION TRIM(WS-E4) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A console command goes to the child as a line (cat answers with it, SPP-READ displays it); an empty one goes nowhere.
     CALL STATIC "cc_wk_proc_spawn" USING BY REFERENCE WS-EXE-CAT BY REFERENCE WS-ARGS-NONE BY REFERENCE WS-SLOT
         RETURNING WS-RC
     MOVE WS-SLOT TO SP-CHILD
     MOVE LOW-VALUES TO WS-CONSOLE
     MOVE "say hello" TO WS-CONSOLE(1:9)
     CALL "SPP-CONSOLE" USING CLIENT-STATE WS-CONSOLE
     MOVE LOW-VALUES TO WS-EMPTY
     CALL "SPP-CONSOLE" USING CLIENT-STATE WS-EMPTY
     MOVE 0 TO WS-E1
     PERFORM VARYING WS-RC FROM 1 BY 1 UNTIL WS-RC > 200 OR WS-E1 = 1
         CALL STATIC "cc_wk_proc_wait" USING BY VALUE SP-CHILD BY VALUE 10 BY REFERENCE WS-STATUS RETURNING WS-WAIT
         CALL "SPP-READ" USING CLIENT-STATE
         IF SP-LINE-LENGTH = 0
             MOVE 1 TO WS-E1
         END-IF
     END-PERFORM
     CALL "SPP-FREE" USING CLIENT-STATE
     MOVE SP-CHILD TO WS-E1
     MOVE SP-PROCESS TO WS-E2
     MOVE SP-ACTIVE TO WS-E3
     MOVE "sp proc SPP-FREE kills the child and ends hosting: no slot, no process mode, not hosting" TO TL-CASE
     MOVE "child 0 process 0 active 0" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING "child " FUNCTION TRIM(WS-E1) " process " FUNCTION TRIM(WS-E2) " active " FUNCTION TRIM(WS-E3)
         DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The pause: held on the pause menu and the open-to-others screen of a world not opened to others, not on the world screen, not once opened.
     MOVE SP-SETTINGS TO CORE-SETTINGS
     MOVE 1 TO CS-HOST-KIND
     MOVE CORE-SETTINGS TO SP-SETTINGS
     MOVE SCR-PAUSE TO SM-SCREEN
     CALL "SP-PAUSE-UPDATE" USING CLIENT-STATE
     MOVE SP-PAUSED TO WS-E1
     MOVE SCR-OPEN-TO-OTHERS TO SM-SCREEN
     CALL "SP-PAUSE-UPDATE" USING CLIENT-STATE
     MOVE SP-PAUSED TO WS-E2
     MOVE SCR-WORLD TO SM-SCREEN
     CALL "SP-PAUSE-UPDATE" USING CLIENT-STATE
     MOVE SP-PAUSED TO WS-E3
     MOVE 2 TO CS-HOST-KIND
     MOVE CORE-SETTINGS TO SP-SETTINGS
     MOVE SCR-PAUSE TO SM-SCREEN
     CALL "SP-PAUSE-UPDATE" USING CLIENT-STATE
     MOVE SP-PAUSED TO WS-E4
     MOVE "sp proc the pause holds on the pause menu and the open-to-others screen of a world not opened to others only" TO TL-CASE
     MOVE "pause 1 open 1 world 0 opened 0" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING "pause " FUNCTION TRIM(WS-E1) " open " FUNCTION TRIM(WS-E2) " world " FUNCTION TRIM(WS-E3)
         " opened " FUNCTION TRIM(WS-E4) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The server program: CC_SERVER_BIN alone when set (an existing file is found, a missing one is not, whatever stands next to the program).
     CALL STATIC "setenv" USING WS-ENV-NAME WS-ENV-SH BY VALUE WS-ONE
     CALL "SPP-FIND" USING WS-PATH WS-FOUND
     MOVE WS-FOUND TO WS-E1
     MOVE WS-PATH(1:7) TO WS-SHORT
     CALL STATIC "setenv" USING WS-ENV-NAME WS-ENV-BAD BY VALUE WS-ONE
     CALL "SPP-FIND" USING WS-PATH WS-FOUND
     MOVE WS-FOUND TO WS-E2
     CALL STATIC "unsetenv" USING WS-ENV-NAME
     MOVE "sp proc CC_SERVER_BIN is the only candidate when it is set: an existing file is found, a missing one is not" TO TL-CASE
     MOVE "found 1 /bin/sh missing 0" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING "found " FUNCTION TRIM(WS-E1) " " WS-SHORT " missing " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   CC_SP_PROCESS=1 asks for the child process mode (SP-DEFAULTS, called by CL-INIT); without it the in-process host stays.
     CALL "SP-DEFAULTS" USING CLIENT-STATE
     MOVE SP-PROCESS-PREF TO WS-E1
     CALL STATIC "setenv" USING WS-ENV-PROCESS WS-ENV-ONE BY VALUE WS-ONE
     CALL "SP-DEFAULTS" USING CLIENT-STATE
     MOVE SP-PROCESS-PREF TO WS-E2
     CALL STATIC "unsetenv" USING WS-ENV-PROCESS
     CALL "SP-DEFAULTS" USING CLIENT-STATE
     MOVE SP-PROCESS-PREF TO WS-E3
     MOVE "sp proc CC_SP_PROCESS=1 selects the child process mode and is off by default" TO TL-CASE
     MOVE "unset 0 set 1 unset again 0" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING "unset " FUNCTION TRIM(WS-E1) " set " FUNCTION TRIM(WS-E2) " unset again " FUNCTION TRIM(WS-E3)
         DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-SP-PROC.
