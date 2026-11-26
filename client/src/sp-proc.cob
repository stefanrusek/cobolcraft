*> The single-player host in a child process (docs/design/singleplayer-process.md): SP-OPEN, when SP-PROCESS-PREF is 1
*> (CC_SP_PROCESS=1), starts cobolcraft-server --hosted (server/src/hosted.cob) instead of opening the core in this process, writes
*> the handshake (the CORE-SETTINGS record, the world path, the superflat preset) to its standard input and joins it over loopback
*> when its "@ready <port> <created>" line arrives (NET-OPEN, offline login as the Player). From then on SP-PUMP is SPP-PUMP: it reads
*> the child's output lines (console lines are displayed on the terminal, the "@" lines are the child's answers), sends @pause and
*> @resume when the pause of the screen changes, and ends hosting when the child ends. SP-STOP is SPP-STOP: "@stop" (the child saves the
*> world and ends; the client waits for it, then kills it after SPP-WAIT-MS), and a client that ends any other way leaves the child
*> with end of input, which saves and ends. When the program cannot be found or started the world opens in this process as before.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPP-FIND.
*> USING path out (PIC X(1100), a z-string), found out (BINARY-LONG): the server program of this build: $CC_SERVER_BIN (when set it is
*> the only candidate: a path that does not exist means not found), else
*> cobolcraft-server in the directory of the running executable, else ../bin/cobolcraft-server of it (a test program in
*> build/<mode>/tests next to build/<mode>/bin).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ENV                 PIC X(1000).
 01 WS-DIR                 PIC X(1000).
 01 WS-N                   BINARY-LONG.
 01 WS-CAP                 BINARY-LONG VALUE 999.
 01 WS-INFO                PIC X(16).
 01 WS-RC                  BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-TRY                 PIC X(1100).
 LINKAGE SECTION.
 01 L-PATH                 PIC X(1100).
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-PATH L-FOUND.
     MOVE 0 TO L-FOUND
     MOVE LOW-VALUES TO L-PATH
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "CC_SERVER_BIN"
     MOVE LOW-VALUES TO WS-DIR
     CALL STATIC "cc_wk_self_dir" USING BY REFERENCE WS-DIR BY VALUE WS-CAP RETURNING WS-N
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 3 OR L-FOUND = 1 OR (WS-K > 1 AND WS-ENV NOT = SPACES)
         MOVE LOW-VALUES TO WS-TRY
         EVALUATE TRUE
             WHEN WS-K = 1 AND WS-ENV NOT = SPACES
                 STRING FUNCTION TRIM(WS-ENV) DELIMITED BY SIZE INTO WS-TRY
             WHEN WS-K = 2 AND WS-N > 0
                 STRING WS-DIR(1:WS-N) "/cobolcraft-server" DELIMITED BY SIZE INTO WS-TRY
             WHEN WS-K = 3 AND WS-N > 0
                 STRING WS-DIR(1:WS-N) "/../bin/cobolcraft-server" DELIMITED BY SIZE INTO WS-TRY
         END-EVALUATE
         IF WS-TRY(1:1) NOT = LOW-VALUE
             CALL "CBL_CHECK_FILE_EXIST" USING WS-TRY WS-INFO RETURNING WS-RC
             IF WS-RC = 0
                 MOVE WS-TRY TO L-PATH
                 MOVE 1 TO L-FOUND
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SPP-FIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPP-START.
*> USING CLIENT-STATE, settings (PIC X(3829), the CORE-SETTINGS SP-OPEN built), world path (PIC X(1200), z-string), superflat preset
*> (PIC X(40), spaces = none), started out (BINARY-LONG): starts the child and writes the handshake. started 1: hosting in a
*> child (SP-PROCESS 1, SP-PROC-STATE 1, the loading screen's progress at its start); 0: no program or no process, one ERROR line
*> was printed and the caller opens the world in this process.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-HANDSHAKE.
    05 HS-SETTINGS         PIC X(3829).
    05 HS-PATH             PIC X(1200).
    05 HS-PRESET           PIC X(40).
 01 WS-EXE                 PIC X(1100).
 01 WS-FOUND               BINARY-LONG.
 01 WS-ARGS                PIC X(16) VALUE Z"--hosted".
 01 WS-RC                  BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-SETTINGS             PIC X(3829).
 01 L-PATH                 PIC X(1200).
 01 L-PRESET               PIC X(40).
 01 L-STARTED              BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-SETTINGS L-PATH L-PRESET L-STARTED.
     MOVE 0 TO L-STARTED WS-RC
     CALL "SPP-FIND" USING WS-EXE WS-FOUND
     IF WS-FOUND = 1
         CALL STATIC "cc_wk_proc_spawn" USING BY REFERENCE WS-EXE BY REFERENCE WS-ARGS
             BY REFERENCE WS-SLOT RETURNING WS-RC
     END-IF
     IF WS-FOUND = 1 AND WS-RC = 0
         MOVE L-SETTINGS TO HS-SETTINGS
         MOVE L-PATH TO HS-PATH
         MOVE L-PRESET TO HS-PRESET
*>       a child that is already gone shows as such to SPP-PUMP (SPP-LOST), so the write needs no check of its own
         CALL STATIC "cc_wk_proc_write" USING BY VALUE WS-SLOT BY REFERENCE WS-HANDSHAKE
             BY VALUE 5069 RETURNING WS-N
         MOVE 1 TO L-STARTED
         MOVE WS-SLOT TO SP-CHILD
     END-IF
     IF L-STARTED = 1
         MOVE 1 TO SP-PROCESS SP-PROC-STATE
         MOVE 0 TO SP-CHILD-PID SP-PAUSE-SENT SP-STOP-ASKED SP-LINE-LENGTH SP-LOAD-READY SP-LOAD-PERMILLE SP-LOAD-FX SP-LOAD-FZ SP-PORT
         MOVE 1 TO SP-LOAD-STATE
         MOVE 49 TO SP-LOAD-TOTAL
         MOVE LOW-VALUES TO SM-LOAD-CELLS
     ELSE
         DISPLAY "ERROR single-player: cannot start the server program, the world runs in this process"
     END-IF
     GOBACK.
 END PROGRAM SPP-START.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPP-SEND.
*> USING CLIENT-STATE, text (PIC X(1100)), length (BINARY-LONG): the text and a newline to the child's standard input (a control
*> line or a console command). A child that has ended is not an error here: SPP-PUMP finds out.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OUT                 PIC X(1101).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-TEXT                 PIC X(1100).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-TEXT L-LENGTH.
     MOVE L-TEXT(1:L-LENGTH) TO WS-OUT(1:L-LENGTH)
     MOVE X"0A" TO WS-OUT(L-LENGTH + 1:1)
     COMPUTE WS-LENGTH = L-LENGTH + 1
     CALL STATIC "cc_wk_proc_write" USING BY VALUE SP-CHILD BY REFERENCE WS-OUT BY VALUE WS-LENGTH
         RETURNING WS-N
     GOBACK.
 END PROGRAM SPP-SEND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPP-CONSOLE.
*> USING CLIENT-STATE, line (PIC X(257), a z-string, as the start-up commands hold it): a console command for the hosted world (the screenshot start-up
*> commands), run by the child with operator permission; its replies come back as console lines.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TEXT                PIC X(1100).
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-LINE                 PIC X(257).
 PROCEDURE DIVISION USING CLIENT-STATE L-LINE.
     MOVE 0 TO WS-LENGTH
     INSPECT L-LINE TALLYING WS-LENGTH FOR CHARACTERS BEFORE INITIAL X"00"
     IF WS-LENGTH > 0
         MOVE SPACES TO WS-TEXT
         MOVE L-LINE(1:WS-LENGTH) TO WS-TEXT
         CALL "SPP-SEND" USING CLIENT-STATE WS-TEXT WS-LENGTH
     END-IF
     GOBACK.
 END PROGRAM SPP-CONSOLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SP-PAUSE-UPDATE.
*> USING CLIENT-STATE: SP-PAUSED for this frame: 1 on the pause menu, the open-to-others screen and the screens whose isPauseScreen is
*> true (the book editor, 40-8 section 3; the command block, test block and jigsaw screens, 40-9 section 3; not the sign editor nor the
*> container screens) of a world not opened to others (US16-4), the tick clock held then so resuming does not catch up.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY COREAPI.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE SP-SETTINGS TO CORE-SETTINGS
     MOVE 0 TO SP-PAUSED
     IF (SM-SCREEN = SCR-PAUSE OR SM-SCREEN = SCR-OPEN-TO-OTHERS OR SM-SCREEN = SCR-BOOK OR SM-SCREEN = SCR-CMDBLOCK
             OR SM-SCREEN = SCR-FORM) AND CS-HOST-KIND = 1
         MOVE 1 TO SP-PAUSED
         COMPUTE SP-NEXT-TICK = CL-NOW-MS + CL-TICK-MS
     END-IF
     GOBACK.
 END PROGRAM SP-PAUSE-UPDATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPP-READ.
*> USING CLIENT-STATE: everything the child has written so far, cut into lines (the partial last line is kept in SP-LINE) and
*> handed to SPP-LINE one by one.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CCSHIM.
 01 WS-AREA                PIC X(8192).
 01 WS-CAP                 BINARY-LONG VALUE 8192.
 01 WS-GOT                 BINARY-LONG.
 01 WS-RC                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE 0 TO WS-RC
     PERFORM UNTIL WS-RC NOT = 0 OR SP-CHILD = 0
         CALL STATIC "cc_wk_proc_read" USING BY VALUE SP-CHILD BY REFERENCE WS-AREA BY VALUE WS-CAP
             BY REFERENCE WS-GOT RETURNING WS-RC
         IF WS-RC = 0
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-GOT OR SP-CHILD = 0
                 EVALUATE TRUE
                     WHEN WS-AREA(WS-I:1) = X"0A"
                         IF SP-LINE-LENGTH > 0
                             CALL "SPP-LINE" USING CLIENT-STATE
                         END-IF
                         MOVE 0 TO SP-LINE-LENGTH
                     WHEN SP-LINE-LENGTH < 4096
                         ADD 1 TO SP-LINE-LENGTH
                         MOVE WS-AREA(WS-I:1) TO SP-LINE(SP-LINE-LENGTH:1)
                 END-EVALUATE
             END-PERFORM
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SPP-READ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPP-LINE.
*> USING CLIENT-STATE: one complete line of the child's output (SP-LINE, SP-LINE-LENGTH > 0):
*>   @ready <port> <created> <pid>   join: NET-OPEN to 127.0.0.1:<port> (once, while SP-PROC-STATE is 1)
*>   @refused <n>              the core refused the world: the child is freed, the world list shows the refusal
*>   @load ...                 SP-LOAD-* and SM-LOAD-CELLS of the loading screen
*>   @opened <port>            SP-PORT of the world opened to others
*>   @stop-requested           SP-STOP-ASKED (SPP-PUMP answers with the quit-world path)
*>   anything else             a console line, displayed on the terminal
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-WORD                PIC X(16).
 01 WS-A                   PIC X(16).
 01 WS-B                   PIC X(16).
 01 WS-C                   PIC X(16).
 01 WS-D                   PIC X(16).
 01 WS-E                   PIC X(16).
 01 WS-F                   PIC X(16).
 01 WS-GRID                PIC X(1225).
 01 WS-PORT                PIC Z(9)9.
 01 WS-ADDRESS             PIC X(256).
 01 WS-ADDRESS-LENGTH      BINARY-LONG.
 01 WS-CONN                BINARY-LONG VALUE CONN-GAME.
 01 WS-NEXT                BINARY-LONG VALUE PH-LOGIN.
 01 WS-CREATED             BINARY-LONG.
 01 WS-REFUSED             BINARY-LONG.
 01 WS-SCREEN              BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE SPACES TO WS-WORD WS-A WS-B WS-C WS-D WS-E WS-F WS-GRID
     UNSTRING SP-LINE(1:SP-LINE-LENGTH) DELIMITED BY SPACE
         INTO WS-WORD WS-A WS-B WS-C WS-D WS-E WS-F WS-GRID
     EVALUATE TRUE
         WHEN WS-WORD = "@ready" AND SP-PROC-STATE = 1
             COMPUTE WS-CREATED = FUNCTION NUMVAL(WS-B)
             COMPUTE SP-CHILD-PID = FUNCTION NUMVAL(WS-C)
             MOVE FUNCTION NUMVAL(WS-A) TO WS-PORT
             MOVE SPACES TO WS-ADDRESS
             STRING "127.0.0.1:" FUNCTION TRIM(WS-PORT) DELIMITED BY SIZE INTO WS-ADDRESS
             MOVE FUNCTION STORED-CHAR-LENGTH(WS-ADDRESS) TO WS-ADDRESS-LENGTH
             MOVE 2 TO SP-PROC-STATE
             CALL "NET-OPEN" USING CLIENT-STATE WS-CONN WS-ADDRESS WS-ADDRESS-LENGTH WS-NEXT
*>           a newly created local world waits 500 ms after the level is ready before Player Loaded (docs/protocol/50 section 7.3)
             IF WS-CREATED = 1
                 MOVE 500 TO PL-CLOSE-DELAY
             END-IF
         WHEN WS-WORD = "@refused"
             COMPUTE WS-REFUSED = FUNCTION NUMVAL(WS-A)
             CALL "SPP-FREE" USING CLIENT-STATE
             MOVE SP-OPENED-FROM TO WS-SCREEN
             CALL "SCREEN-OPEN" USING CLIENT-STATE WS-SCREEN
*>           1: the packs are not ok; 2: any other refusal of the core (no world type, no level.dat)
             MOVE 2 TO SP-CREATE-REFUSED
             IF WS-REFUSED = 1
                 MOVE 1 TO SP-CREATE-REFUSED
             END-IF
         WHEN WS-WORD = "@load"
             COMPUTE SP-LOAD-STATE = FUNCTION NUMVAL(WS-A)
             COMPUTE SP-LOAD-READY = FUNCTION NUMVAL(WS-B)
             COMPUTE SP-LOAD-TOTAL = FUNCTION NUMVAL(WS-C)
             COMPUTE SP-LOAD-PERMILLE = FUNCTION NUMVAL(WS-D)
             COMPUTE SP-LOAD-FX = FUNCTION NUMVAL(WS-E)
             COMPUTE SP-LOAD-FZ = FUNCTION NUMVAL(WS-F)
             INSPECT WS-GRID CONVERTING "ABCDEFGHIJK" TO X"000102030405060708090A"
             MOVE WS-GRID TO SM-LOAD-CELLS
         WHEN WS-WORD = "@opened"
             COMPUTE SP-PORT = FUNCTION NUMVAL(WS-A)
         WHEN WS-WORD = "@stop-requested"
             MOVE 1 TO SP-STOP-ASKED
*>       any other control line (an @ready while stopping, a message of a newer child) is ignored
         WHEN WS-WORD(1:1) = "@"
             CONTINUE
         WHEN OTHER
             DISPLAY SP-LINE(1:SP-LINE-LENGTH)
     END-EVALUATE
     GOBACK.
 END PROGRAM SPP-LINE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPP-FREE.
*> USING CLIENT-STATE: the child's slot is freed (killed first when it still runs) and hosting is over: no child, no hosting, the
*> pause and the world opened to others forgotten.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-RC                  BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     IF SP-CHILD > 0
         CALL STATIC "cc_wk_proc_stop" USING BY VALUE SP-CHILD RETURNING WS-RC
     END-IF
     MOVE 0 TO SP-CHILD SP-PROCESS SP-PROC-STATE SP-PAUSE-SENT SP-PORT SP-ADDR-COUNT SP-ACTIVE SP-PAUSED
     GOBACK.
 END PROGRAM SPP-FREE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPP-LOST.
*> USING CLIENT-STATE: the child ended while it was hosting (a crash, a fatal error, a kill): its last output is displayed, the
*> disconnect screen shows the lost connection (NET-FAIL), the child is freed.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-CONN                BINARY-LONG VALUE CONN-GAME.
 01 WS-DETAIL              PIC X(512) VALUE "the single-player process ended".
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     CALL "SPP-READ" USING CLIENT-STATE
     CALL "SPP-FREE" USING CLIENT-STATE
     CALL "NET-FAIL" USING CLIENT-STATE WS-CONN WS-DETAIL
     GOBACK.
 END PROGRAM SPP-LOST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPP-PUMP.
*> USING CLIENT-STATE (hosting in a child): the frame's work of SP-PUMP without ticks: the child's output (SPP-READ), the pause
*> (@pause or @resume when SP-PAUSED changed, once the game connection is open), the end of the child (SPP-LOST), the stop
*> command (@stop-requested: SP-QUIT, as SP-PUMP does for run state 1), and the end of the game connection (SP-STOP).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-CONN                BINARY-LONG VALUE CONN-GAME.
 01 WS-PAUSE               PIC X(1100) VALUE "@pause".
 01 WS-RESUME              PIC X(1100) VALUE "@resume".
 01 WS-LENGTH              BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-RC                  BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     CALL "SP-PAUSE-UPDATE" USING CLIENT-STATE
     CALL "SPP-READ" USING CLIENT-STATE
     IF SP-CHILD > 0 AND SP-PROC-STATE = 2 AND SP-PAUSED NOT = SP-PAUSE-SENT
         MOVE SP-PAUSED TO SP-PAUSE-SENT
         IF SP-PAUSED = 1
             MOVE 6 TO WS-LENGTH
             CALL "SPP-SEND" USING CLIENT-STATE WS-PAUSE WS-LENGTH
         ELSE
             MOVE 7 TO WS-LENGTH
             CALL "SPP-SEND" USING CLIENT-STATE WS-RESUME WS-LENGTH
         END-IF
     END-IF
     IF SP-CHILD > 0
         CALL STATIC "cc_wk_proc_wait" USING BY VALUE SP-CHILD BY VALUE 0 BY REFERENCE WS-STATUS
             RETURNING WS-RC
         EVALUATE TRUE
             WHEN WS-RC = 0
                 CALL "SPP-LOST" USING CLIENT-STATE
             WHEN SP-STOP-ASKED = 1
*>               What the child sent before is received first.
                 CALL "NET-PUMP" USING CLIENT-STATE WS-CONN
                 CALL "SP-QUIT" USING CLIENT-STATE
             WHEN SP-PROC-STATE = 2 AND CN-PHASE(CONN-GAME) = PH-NONE
                 CALL "SP-STOP" USING CLIENT-STATE
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM SPP-PUMP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPP-STOP.
*> USING CLIENT-STATE (hosting in a child): "@stop", then the child's output is displayed until it ends (the world is saved
*> by then), at most SPP-WAIT-MS (15 s); one that still runs is killed. The child's slot is freed.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-STOP                PIC X(1100) VALUE "@stop".
 01 WS-LENGTH              BINARY-LONG VALUE 5.
 01 WS-STATUS              BINARY-LONG.
 01 WS-RC                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE 3 TO SP-PROC-STATE
     CALL "SPP-SEND" USING CLIENT-STATE WS-STOP WS-LENGTH
     MOVE 1 TO WS-RC
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 300 OR WS-RC = 0
         CALL "SPP-READ" USING CLIENT-STATE
         CALL STATIC "cc_wk_proc_wait" USING BY VALUE SP-CHILD BY VALUE 50 BY REFERENCE WS-STATUS
             RETURNING WS-RC
     END-PERFORM
     CALL "SPP-READ" USING CLIENT-STATE
     CALL "SPP-FREE" USING CLIENT-STATE
     GOBACK.
 END PROGRAM SPP-STOP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPP-OPEN-OTHERS.
*> USING CLIENT-STATE (hosting in a child, not yet opened): "@open <guest mode> <guest operator>", then waits (at most 5 s) for
*> the child's "@opened <port>" (SP-PORT).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TEXT                PIC X(1100).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-RC                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-MODE                PIC 9.
 01 WS-OPERATOR            PIC 9.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE SP-GUEST-MODE TO WS-MODE
     MOVE SP-GUEST-OPERATOR TO WS-OPERATOR
     MOVE SPACES TO WS-TEXT
     STRING "@open " WS-MODE " " WS-OPERATOR DELIMITED BY SIZE INTO WS-TEXT
     MOVE 8 TO WS-LENGTH
     CALL "SPP-SEND" USING CLIENT-STATE WS-TEXT WS-LENGTH
     MOVE 0 TO SP-PORT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 1000 OR SP-PORT > 0 OR SP-CHILD = 0
         CALL "SPP-READ" USING CLIENT-STATE
         CALL STATIC "cc_wk_proc_wait" USING BY VALUE SP-CHILD BY VALUE 5 BY REFERENCE WS-STATUS
             RETURNING WS-RC
     END-PERFORM
     GOBACK.
 END PROGRAM SPP-OPEN-OTHERS.
