*> The server's main loop (research R6; contracts/core-host-api.md §2, operator-surface.md §1 to §3):
*> SV-START (settings, CORE-WORLD-OPEN of ./world, listen), SV-ITERATE (one loop iteration: poll up
*> to the next tick, accept, pump, due ticks, flush, display drained console lines) and SV-SHUTDOWN.
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
*> Empties the host state, takes the settings (the operator-surface §2 defaults: creative,
*> "A CobolCraft server", view distance 8, player combat, hostile mobs, weather changes and extra
*> dimensions on, allow-list off, no pack offer, port 25565), opens ./world with CORE-WORLD-OPEN
*> (a dedicated server, host kind 0), listens on the port and starts the tick clock.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY SVSTATE.
 COPY COREAPI.
 01 WS-WORLD               PIC X(16) VALUE Z"./world".
 01 WS-CREATED             BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-NOW                 BINARY-DOUBLE.
 PROCEDURE DIVISION.
     MOVE 0 TO SV-LISTENER SV-BOUND-PORT SV-TICKS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SV-MAX-CONNS
         MOVE 0 TO SV-HANDLE(WS-I) SV-CORE-ID(WS-I) SV-CLOSING(WS-I) SV-OUT-PENDING(WS-I)
         MOVE 1 TO SV-OUT-START(WS-I)
     END-PERFORM
     INITIALIZE CORE-SETTINGS
     MOVE 25565 TO SV-PORT
     MOVE 1 TO CS-DEFAULT-MODE
     MOVE "A CobolCraft server" TO CS-DESCRIPTION
     MOVE 8 TO CS-VIEW-DISTANCE
     MOVE 1 TO CS-PLAYER-COMBAT CS-HOSTILE-MOBS CS-WEATHER-CHANGES CS-EXTRA-DIMENSIONS
     MOVE 0 TO CS-ALLOW-LIST-ENFORCED CS-PACK-OFFERED CS-PACK-REQUIRED CS-HOST-KIND
     MOVE "world" TO CS-NEW-WORLD-NAME
     MOVE CORE-SETTINGS TO SV-SETTINGS
     CALL "CORE-WORLD-OPEN" USING WS-WORLD CORE-SETTINGS WS-CREATED
     CALL "TCP-LISTEN" USING SV-PORT
     CALL "SV-NOW-MS" USING WS-NOW
     COMPUTE SV-NEXT-TICK = WS-NOW + SV-TICK-MS
     GOBACK.
 END PROGRAM SV-START.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SV-ITERATE.
*> One loop iteration: cc_net_poll waits no longer than the time left to the next tick (TCP-POLL
*> accepts and receives), every due tick runs (one CORE-TICK per elapsed 50 ms, however many are
*> due), the outbound bytes are flushed and the pending console lines are displayed one per line.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY SVSTATE.
 COPY COREAPI.
 01 WS-NOW                 BINARY-DOUBLE.
 01 WS-TIMEOUT             BINARY-LONG.
 01 WS-AREA                PIC X(65537).
 01 WS-I                   BINARY-LONG.
 01 WS-FROM                BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-PTR                 USAGE POINTER.
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
 END PROGRAM SV-ITERATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SV-SHUTDOWN.
*> Closes every connection and the listener (TCP-CLOSE-ALL).
 PROCEDURE DIVISION.
     CALL "TCP-CLOSE-ALL"
     GOBACK.
 END PROGRAM SV-SHUTDOWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SV-PRINT.
*> USING text address (POINTER), length (BINARY-LONG, > 0): displays that text as one console line
*> (operator-surface §3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 B-TEXT                 PIC X(65536) BASED.
 LINKAGE SECTION.
 01 L-PTR                  USAGE POINTER.
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-PTR L-LENGTH.
     SET ADDRESS OF B-TEXT TO L-PTR
     DISPLAY B-TEXT(1:L-LENGTH)
     GOBACK.
 END PROGRAM SV-PRINT.
