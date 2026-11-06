*> The server's main loop (research R6; contracts/core-host-api.md §2, operator-surface.md §1 to §3):
*> SV-START (settings, CORE-WORLD-OPEN of ./world, listen), SV-ITERATE (one loop iteration: poll up
*> to the next tick, accept, pump, read the console, due ticks, flush, display drained console lines,
*> the stop sequence SV-STOP once stop is requested), SV-SHUTDOWN, and SV-MAIN (SV-START, then
*> SV-RUN: iterate until stopped, shut down, exit status 0).
*> One thread: COBOL has no portable threads and the loop needs none. Host state: SVSTATE.cpy.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SV-NOW-MS.
*> USING milliseconds out (BINARY-DOUBLE): the wall clock in milliseconds (10 ms resolution of
*> FUNCTION CURRENT-DATE), counted from day 1 of INTEGER-OF-DATE so midnight does not wrap.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NOW                 PIC X(21).
 LINKAGE SECTION.
 01 L-MS                   BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-MS.
     MOVE FUNCTION CURRENT-DATE TO WS-NOW
     COMPUTE L-MS = (FUNCTION INTEGER-OF-DATE(FUNCTION NUMVAL(WS-NOW(1:8))) * 86400
         + FUNCTION NUMVAL(WS-NOW(9:2)) * 3600 + FUNCTION NUMVAL(WS-NOW(11:2)) * 60
         + FUNCTION NUMVAL(WS-NOW(13:2))) * 1000 + FUNCTION NUMVAL(WS-NOW(15:2)) * 10
     GOBACK.
 END PROGRAM SV-NOW-MS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SV-START.
*> Empties the host state, takes the settings and the port from ./cobolcraft-server.conf
*> (SV-CONFIG-LOAD: the operator-surface §2 defaults for missing keys, the file written when absent),
*> opens ./world with CORE-WORLD-OPEN (a dedicated server, host kind 0; "Created new world in
*> ./world" when it had none), listens on the port ("Ready: accepting players on 0.0.0.0:<port>",
*> operator-surface §3, US13-1) and starts the tick clock.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY SVSTATE.
 COPY COREAPI.
 01 WS-WORLD               PIC X(16) VALUE Z"./world".
 01 WS-CREATED             BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-NOW                 BINARY-DOUBLE.
 01 WS-LINE                PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-EDIT                PIC Z(9)9.
 01 WS-PTR                 USAGE POINTER.
 PROCEDURE DIVISION.
     SET WS-PTR TO ADDRESS OF WS-LINE
     MOVE 0 TO SV-LISTENER SV-BOUND-PORT SV-TICKS
     MOVE 1 TO SV-CONSOLE-OPEN
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SV-MAX-CONNS
         MOVE 0 TO SV-HANDLE(WS-I) SV-CORE-ID(WS-I) SV-CLOSING(WS-I) SV-OUT-PENDING(WS-I)
         MOVE 1 TO SV-OUT-START(WS-I)
     END-PERFORM
     CALL "SV-CONFIG-LOAD" USING CORE-SETTINGS SV-PORT
     MOVE CORE-SETTINGS TO SV-SETTINGS
     CALL "CORE-WORLD-OPEN" USING WS-WORLD CORE-SETTINGS WS-CREATED
     IF WS-CREATED = 1
         MOVE "Created new world in ./world" TO WS-LINE
         MOVE 28 TO WS-LENGTH
         CALL "SV-PRINT" USING WS-PTR WS-LENGTH
     END-IF
     CALL "TCP-LISTEN" USING SV-PORT
*>   The ready line (US13-1): the listener binds 0.0.0.0, every interface.
     MOVE SV-BOUND-PORT TO WS-EDIT
     MOVE SPACES TO WS-LINE
     STRING "Ready: accepting players on 0.0.0.0:" FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE
         INTO WS-LINE
     COMPUTE WS-LENGTH = 36 + FUNCTION LENGTH(FUNCTION TRIM(WS-EDIT))
     CALL "SV-PRINT" USING WS-PTR WS-LENGTH
     CALL "SV-NOW-MS" USING WS-NOW
     COMPUTE SV-NEXT-TICK = WS-NOW + SV-TICK-MS
     GOBACK.
 END PROGRAM SV-START.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SV-ITERATE.
*> One loop iteration: cc_net_poll waits no longer than the time left to the next tick (TCP-POLL
*> accepts, receives and reads the console), every due tick runs (one CORE-TICK per elapsed 50 ms,
*> however many are due), the outbound bytes are flushed and the pending console lines are displayed one per line
*> (SV-DRAIN). When the stop command has requested a stop (run state 1), SV-STOP follows.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY SVSTATE.
 COPY COREAPI.
 01 WS-NOW                 BINARY-DOUBLE.
 01 WS-TIMEOUT             BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "SV-NOW-MS" USING WS-NOW
     COMPUTE WS-TIMEOUT = FUNCTION MAX(0, FUNCTION MIN(SV-TICK-MS, SV-NEXT-TICK - WS-NOW))
     CALL "TCP-POLL" USING WS-TIMEOUT
     CALL "SV-NOW-MS" USING WS-NOW
     PERFORM UNTIL WS-NOW < SV-NEXT-TICK
         CALL "CORE-TICK"
         ADD 1 TO SV-TICKS
         ADD SV-TICK-MS TO SV-NEXT-TICK
     END-PERFORM
     CALL "TCP-FLUSH"
     CALL "SV-DRAIN"
*>   A stop requested by the stop command (run state 1) is carried out now (US15-2).
     CALL "CORE-STATUS-GET" USING CORE-STATUS
     IF CST-RUN-STATE = 1
         CALL "SV-STOP"
     END-IF
     GOBACK.
 END PROGRAM SV-ITERATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SV-SHUTDOWN.
*> Closes every connection and the listener (TCP-CLOSE-ALL).
 PROCEDURE DIVISION.
     CALL "TCP-CLOSE-ALL"
     GOBACK.
 END PROGRAM SV-SHUTDOWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SV-DRAIN.
*> Displays every pending console line (CORE-CONSOLE-DRAIN) through SV-PRINT, one per line.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY COREAPI.
 01 WS-AREA                PIC X(65537).
 01 WS-I                   BINARY-LONG.
 01 WS-FROM                BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-PTR                 USAGE POINTER.
 PROCEDURE DIVISION.
     MOVE 1 TO CB-LENGTH
     PERFORM UNTIL CB-LENGTH = 0
         SET CB-ADDR TO ADDRESS OF WS-AREA
         MOVE 65536 TO CB-CAPACITY
         MOVE 0 TO CB-LENGTH
         CALL "CORE-CONSOLE-DRAIN" USING CORE-BUFFER
         MOVE 1 TO WS-FROM
*>       Each line ends at a newline; the end of the drained bytes ends a line too.
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CB-LENGTH + 1 OR CB-LENGTH = 0
             IF WS-I > CB-LENGTH OR WS-AREA(WS-I:1) = X"0A"
                 COMPUTE WS-LENGTH = WS-I - WS-FROM
                 IF WS-LENGTH > 0
                     SET WS-PTR TO ADDRESS OF WS-AREA(WS-FROM:1)
                     CALL "SV-PRINT" USING WS-PTR WS-LENGTH
                 END-IF
                 COMPUTE WS-FROM = WS-I + 1
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM SV-DRAIN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SV-STOP.
*> The stop sequence (US15-2; core-host-api.md §2; operator-surface.md §3): "Stopping: saving world
*> and disconnecting players", CORE-STOP with the stopping text (standin-content §17
*> cobolcraft.disconnect.shutdown: the world is saved, every connection is sent its Disconnect, run
*> state 2), the Disconnects flushed (each transport closed once its close flag is handed back), the
*> pending console lines displayed, then "Stopped". The caller exits after run state 2 (SV-RUN).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-REASON              PIC X(32) VALUE Z"cobolcraft.disconnect.shutdown".
 01 WS-STOPPING            PIC X(48) VALUE "Stopping: saving world and disconnecting players".
 01 WS-STOPPED             PIC X(8) VALUE "Stopped".
 01 WS-LENGTH              BINARY-LONG.
 01 WS-PTR                 USAGE POINTER.
 PROCEDURE DIVISION.
     SET WS-PTR TO ADDRESS OF WS-STOPPING
     MOVE 48 TO WS-LENGTH
     CALL "SV-PRINT" USING WS-PTR WS-LENGTH
     CALL "CORE-STOP" USING WS-REASON
     CALL "TCP-FLUSH"
     CALL "SV-DRAIN"
     SET WS-PTR TO ADDRESS OF WS-STOPPED
     MOVE 7 TO WS-LENGTH
     CALL "SV-PRINT" USING WS-PTR WS-LENGTH
     GOBACK.
 END PROGRAM SV-STOP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SV-RUN.
*> Runs the loop of a started server (SV-START): SV-ITERATE until the run state is 2 (stopped,
*> CORE-STATUS-GET), then SV-SHUTDOWN, and ends the run with exit status 0. Never returns.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY COREAPI.
 PROCEDURE DIVISION.
     CALL "CORE-STATUS-GET" USING CORE-STATUS
     PERFORM UNTIL CST-RUN-STATE = 2
         CALL "SV-ITERATE"
         CALL "CORE-STATUS-GET" USING CORE-STATUS
     END-PERFORM
     CALL "SV-SHUTDOWN"
     STOP RUN RETURNING 0.
 END PROGRAM SV-RUN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SV-MAIN.
*> The server program (cobolcraft-server, operator-surface.md §1; test-harness.md §2): SV-START in
*> the current directory, then SV-RUN, which ends the run with the exit status. Never returns.
 PROCEDURE DIVISION.
     CALL "SV-START"
     CALL "SV-RUN".
 END PROGRAM SV-MAIN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SV-PRINT.
*> USING text address (POINTER), length (BINARY-LONG, > 0): displays that text as one console line
*> prefixed with the local time as "[HH:MM:SS] " (operator-surface §3, US13-3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NOW                 PIC X(21).
 01 B-TEXT                 PIC X(65536) BASED.
 LINKAGE SECTION.
 01 L-PTR                  USAGE POINTER.
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-PTR L-LENGTH.
     SET ADDRESS OF B-TEXT TO L-PTR
     MOVE FUNCTION CURRENT-DATE TO WS-NOW
     DISPLAY "[" WS-NOW(9:2) ":" WS-NOW(11:2) ":" WS-NOW(13:2) "] " B-TEXT(1:L-LENGTH)
     GOBACK.
 END PROGRAM SV-PRINT.
