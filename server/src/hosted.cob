*> The server program in the single-player role (docs/design/singleplayer-process.md): a client that hosts a world on its own
*> machine starts `cobolcraft-server --hosted` as a child process and joins it over loopback, so the core ticks run on another
*> processor core. Everything the client says arrives on standard input, everything the program says goes to standard output:
*>   handshake  (parent to child, raw bytes, read once): the CORE-SETTINGS record the client built (3829 bytes), the world path as
*>              a z-string (1200 bytes) and the superflat preset (40 bytes, spaces = none): 5069 bytes
*>   @ready <port> <created> <pid>   the world is open and the loopback listener is up (created 1 when the folder had no level.dat; the
*>              process id lets a test see that the process is gone)
*>   @refused <n>              the core refused the world (CORE-WORLD-OPEN flag minus n); exit status 10
*>   @load <state> <ready> <total> <permille> <fx> <fz> <grid>   the spawn search and spawn area progress (GEN-LOAD-PROGRESS) and the
*>              35 x 35 cells of GEN-LOAD-GRID, each one letter A plus the cell code, at most every 100 ms while it runs and once
*>              more with state 0
*>   @opened <port>            the world was opened to others: the listener is now on every interface at that port
*>   any other line            a console line of the core (printed without the server's time stamp)
*>   control lines (client to child): @pause, @resume, @open <guest mode> <guest operator>, @stop; any other line is a console
*>              command (CORE-CONSOLE). End of input is a stop: the world is saved and the program ends.
*> Host state: SVSTATE.cpy (SV-HOSTED, SV-LOOPBACK, SV-PAUSED, SV-STOP-WANTED, SV-LOAD-*).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SV-HOSTED-ARG.
*> USING flag out (BINARY-LONG): 1 when the command line is --hosted, else 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ARG                 PIC X(256).
 LINKAGE SECTION.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-FLAG.
     MOVE SPACES TO WS-ARG
     ACCEPT WS-ARG FROM COMMAND-LINE
     MOVE 0 TO L-FLAG
     IF FUNCTION TRIM(WS-ARG) = "--hosted"
         MOVE 1 TO L-FLAG
     END-IF
     GOBACK.
 END PROGRAM SV-HOSTED-ARG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SV-HOSTED-READ.
*> USING area (the 5069 bytes of the handshake), ok out (BINARY-LONG): reads exactly that many bytes from standard input
*> (read(0), blocking: the client writes them at once); ok 0 when the input ended first.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-FD                  BINARY-LONG VALUE 0.
 01 WS-GOT                 BINARY-DOUBLE.
 01 WS-WANT                BINARY-DOUBLE.
 01 WS-N                   BINARY-DOUBLE.
 01 WS-PTR                 USAGE POINTER.
 LINKAGE SECTION.
 01 L-AREA                 PIC X(5069).
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-AREA L-OK.
     MOVE 0 TO WS-GOT
     MOVE 1 TO WS-N
     PERFORM UNTIL WS-GOT = 5069 OR WS-N <= 0
         SET WS-PTR TO ADDRESS OF L-AREA(WS-GOT + 1:1)
         COMPUTE WS-WANT = 5069 - WS-GOT
         CALL STATIC "read" USING BY VALUE WS-FD BY VALUE WS-PTR BY VALUE WS-WANT RETURNING WS-N
         IF WS-N > 0
             ADD WS-N TO WS-GOT
         END-IF
     END-PERFORM
     MOVE 0 TO L-OK
     IF WS-GOT = 5069
         MOVE 1 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM SV-HOSTED-READ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SV-HOSTED-CHECK.
*> USING ok (BINARY-LONG): fatal when the handshake did not arrive (the client ended before it wrote it).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-FATAL               PIC X(64).
 LINKAGE SECTION.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-OK.
     IF L-OK = 0
         MOVE LOW-VALUES TO WS-FATAL
         MOVE "hosted: the handshake did not arrive" TO WS-FATAL
         CALL STATIC "cc_fatal" USING BY REFERENCE WS-FATAL
     END-IF
     GOBACK.
 END PROGRAM SV-HOSTED-CHECK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SV-HOSTED-REFUSE.
*> USING created (BINARY-LONG): when CORE-WORLD-OPEN refused the world (the flag is minus its status), prints "@refused <n>" and
*> ends the run with exit status 10, as the server does for a world it cannot open. Otherwise nothing.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   PIC 9.
 LINKAGE SECTION.
 01 L-CREATED              BINARY-LONG.
 PROCEDURE DIVISION USING L-CREATED.
     IF L-CREATED < 0
         COMPUTE WS-N = 0 - L-CREATED
         DISPLAY "@refused " WS-N
         STOP RUN RETURNING 10
     END-IF
     GOBACK.
 END PROGRAM SV-HOSTED-REFUSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SV-HOSTED-START.
*> The single-player counterpart of SV-START: reads the handshake, makes the generation workers ready (they fork from this
*> process), sets the pending superflat preset, opens the world with the client's settings (saved at once when created, so the
*> world list shows it), listens on 127.0.0.1 (system-chosen port) and prints "@ready <port> <created>". Fatal when the handshake
*> does not arrive.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY SVSTATE.
 COPY COREAPI.
 01 WS-HANDSHAKE.
    05 HS-SETTINGS         PIC X(3829).
    05 HS-PATH             PIC X(1200).
    05 HS-PRESET           PIC X(40).
 01 WS-OK                  BINARY-LONG.
 01 WS-CREATED             BINARY-LONG.
 01 WS-PRESET-STATUS       BINARY-LONG.
 01 WS-NOW                 BINARY-DOUBLE.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-PORT                PIC Z(9)9.
 01 WS-PID                 BINARY-LONG.
 01 WS-PID-EDIT            PIC Z(9)9.
 PROCEDURE DIVISION.
     CALL "SV-SLOTS-INIT"
     MOVE 1 TO SV-HOSTED SV-LOOPBACK
     CALL "SV-HOSTED-READ" USING WS-HANDSHAKE WS-OK
     CALL "SV-HOSTED-CHECK" USING WS-OK
     MOVE HS-SETTINGS TO CORE-SETTINGS
     MOVE CORE-SETTINGS TO SV-SETTINGS
     CALL "GEN-WORKERS-AUTO"
     IF HS-PRESET NOT = SPACES
         CALL "FLAT-PRESET-SET" USING HS-PRESET WS-PRESET-STATUS
     END-IF
     CALL "CORE-WORLD-OPEN" USING HS-PATH CORE-SETTINGS WS-CREATED
     CALL "SV-HOSTED-REFUSE" USING WS-CREATED
     IF WS-CREATED = 1
         CALL "CORE-SAVE"
     END-IF
     CALL "TCP-LISTEN" USING WS-ZERO
     MOVE SV-BOUND-PORT TO WS-PORT
     CALL STATIC "getpid" RETURNING WS-PID
     MOVE WS-PID TO WS-PID-EDIT
     DISPLAY "@ready " FUNCTION TRIM(WS-PORT) " " WS-CREATED " " FUNCTION TRIM(WS-PID-EDIT)
     CALL "SV-NOW-MS" USING WS-NOW
     COMPUTE SV-NEXT-TICK = WS-NOW + SV-TICK-MS
     GOBACK.
 END PROGRAM SV-HOSTED-START.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SV-CONTROL.
*> USING line (PIC X(1025), a control line of the client without its newline, z-string, first character "@"): @pause and
*> @resume hold and release the tick clock, @open <mode> <operator> opens the world to others (CORE-OPEN-TO-OTHERS, the listener
*> moves to every interface), @stop asks for the stop sequence. An unknown control line is ignored.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY SVSTATE.
 01 WS-WORD                PIC X(16).
 01 WS-A                   PIC X(16).
 01 WS-B                   PIC X(16).
 01 WS-MODE                BINARY-LONG.
 01 WS-OPERATOR            BINARY-LONG.
 01 WS-NOW                 BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-LINE                 PIC X(1025).
 PROCEDURE DIVISION USING L-LINE.
     MOVE SPACES TO WS-WORD WS-A WS-B
     UNSTRING L-LINE DELIMITED BY ALL SPACE OR X"00" INTO WS-WORD WS-A WS-B
     EVALUATE WS-WORD
         WHEN "@pause"
             MOVE 1 TO SV-PAUSED
         WHEN "@resume"
             MOVE 0 TO SV-PAUSED
             CALL "SV-NOW-MS" USING WS-NOW
             COMPUTE SV-NEXT-TICK = WS-NOW + SV-TICK-MS
         WHEN "@open"
             COMPUTE WS-MODE = FUNCTION NUMVAL(WS-A)
             COMPUTE WS-OPERATOR = FUNCTION NUMVAL(WS-B)
             CALL "CORE-OPEN-TO-OTHERS" USING WS-MODE WS-OPERATOR
             CALL "SV-HOSTED-OPEN"
         WHEN "@stop"
             MOVE 1 TO SV-STOP-WANTED
     END-EVALUATE
     GOBACK.
 END PROGRAM SV-CONTROL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SV-HOSTED-OPEN.
*> The world was opened to others: the loopback listener is closed and a listener on every interface (system-chosen port) takes
*> its place; prints "@opened <port>". The connections already accepted (the host's own) stay.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY SVSTATE.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-PORT                PIC Z(9)9.
 PROCEDURE DIVISION.
     CALL STATIC "cc_net_close" USING BY VALUE SV-LISTENER
     MOVE 0 TO SV-LOOPBACK
     CALL "TCP-LISTEN" USING WS-ZERO
     MOVE SV-BOUND-PORT TO WS-PORT
     DISPLAY "@opened " FUNCTION TRIM(WS-PORT)
     GOBACK.
 END PROGRAM SV-HOSTED-OPEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SV-HOSTED-LOAD.
*> Once per loop iteration of the single-player role: while the spawn search or the spawn area runs (GEN-LOAD-PROGRESS state not 0),
*> and once more when it has ended, prints the "@load" line at most every 100 ms (at once when the state changed).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY SVSTATE.
 01 WS-STATE               BINARY-LONG.
 01 WS-READY               BINARY-LONG.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-PERMILLE            BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-NOW                 BINARY-DOUBLE.
 01 WS-GRID                PIC X(1225).
 01 WS-LINE                PIC X(1400).
 01 WS-PTR                 BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-E4                  PIC -(9)9.
 01 WS-E5                  PIC -(9)9.
 01 WS-E6                  PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "SV-NOW-MS" USING WS-NOW
     CALL "GEN-LOAD-PROGRESS" USING WS-STATE WS-READY WS-TOTAL WS-PERMILLE WS-FX WS-FZ
     IF SV-HOSTED = 1 AND (WS-STATE > 0 OR SV-LOAD-STATE > 0)
             AND (WS-STATE NOT = SV-LOAD-STATE OR WS-NOW - SV-LOAD-MS >= 100)
         CALL "GEN-LOAD-GRID" USING WS-GRID
         INSPECT WS-GRID CONVERTING X"000102030405060708090A" TO "ABCDEFGHIJK"
         MOVE WS-STATE TO WS-E1
         MOVE WS-READY TO WS-E2
         MOVE WS-TOTAL TO WS-E3
         MOVE WS-PERMILLE TO WS-E4
         MOVE WS-FX TO WS-E5
         MOVE WS-FZ TO WS-E6
         MOVE 1 TO WS-PTR
         MOVE SPACES TO WS-LINE
         STRING "@load " FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) " "
             FUNCTION TRIM(WS-E4) " " FUNCTION TRIM(WS-E5) " " FUNCTION TRIM(WS-E6) " " WS-GRID
             DELIMITED BY SIZE INTO WS-LINE WITH POINTER WS-PTR
         SUBTRACT 1 FROM WS-PTR
         DISPLAY WS-LINE(1:WS-PTR)
         MOVE WS-STATE TO SV-LOAD-STATE
         MOVE WS-NOW TO SV-LOAD-MS
     END-IF
     GOBACK.
 END PROGRAM SV-HOSTED-LOAD.
