*> Console input of the server (contracts/operator-surface.md §4, US15; shim-abi.md §4). TCP-POLL
*> calls SV-CONSOLE-READ when cc_net_poll reports the console ready. Host state: SVSTATE.cpy.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SV-CONSOLE-READ.
*> Reads every complete line available on the console (cc_con_readline, never blocking) and passes
*> each to CORE-CONSOLE as a z-string: a command of the command set without a leading "/", run with
*> operator permission; its result or error is printed with the drained console lines (US15-1,
*> US15-3). A blank line runs nothing. At the end of input the console is no longer read
*> (SV-CONSOLE-OPEN 0) and the server goes on as before (operator-surface §4).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY SVSTATE.
 COPY CCSHIM.
 01 WS-RC                  BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 1024.
 01 WS-LINE                PIC X(1025).
 PROCEDURE DIVISION.
     MOVE 0 TO WS-RC
     PERFORM UNTIL WS-RC NOT = 0
         CALL STATIC "cc_con_readline" USING BY REFERENCE WS-LINE BY VALUE WS-CAPACITY
             BY REFERENCE WS-LENGTH RETURNING WS-RC
         IF WS-RC = 0 AND WS-LENGTH > 0
             MOVE X"00" TO WS-LINE(WS-LENGTH + 1:1)
             CALL "CORE-CONSOLE" USING WS-LINE
         END-IF
     END-PERFORM
     IF WS-RC = CC-CLOSED
         MOVE 0 TO SV-CONSOLE-OPEN
     END-IF
     GOBACK.
 END PROGRAM SV-CONSOLE-READ.
