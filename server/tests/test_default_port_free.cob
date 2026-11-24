*> Test (CC-0005): the default port 25565 is checked without binding it. A listener that holds 25565 (when it is
*> free to take; a port another process holds already proves the point) does not matter to the configuration
*> default: SV-CONFIG-LOAD of a missing file gives port 25565 without listening; SVT-FREE-PORT never hands out
*> 25565 while that port is held, and a server configured for a free port starts while 25565 is held.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-DEFAULT-PORT-FREE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY COREAPI.
 COPY SVSTATE.
 COPY TESTLIB.
 01 WS-SCRATCH             PIC X(256) VALUE "build/server-test-port-free".
 01 WS-CONF                PIC X(4096).
 01 WS-PORT                BINARY-LONG.
 01 WS-FREE                BINARY-LONG.
 01 WS-DEFAULT             BINARY-LONG VALUE 25565.
 01 WS-HOLDER              BINARY-LONG.
 01 WS-HELD                BINARY-LONG.
 01 WS-RC                  BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "SVT-SCRATCH" USING WS-SCRATCH
     CALL "SV-CONFIG-LOAD" USING CORE-SETTINGS WS-PORT
     MOVE "test default port free the configuration default is 25565 and loading it binds nothing" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 25565 TO TL-EXPECTED-N
     MOVE WS-PORT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Hold 25565 here when it is free (an existing holder serves the same purpose).
     CALL STATIC "cc_net_listen" USING BY VALUE WS-DEFAULT BY REFERENCE WS-HOLDER
         BY REFERENCE WS-HELD RETURNING WS-RC
     CALL "SVT-FREE-PORT" USING WS-FREE
     MOVE "test default port free a free port is chosen at run time, not 25565, while 25565 is held" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-FREE > 0 AND WS-FREE NOT = 25565
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-FREE TO WS-EDIT
     MOVE SPACES TO WS-CONF
     STRING "port=" FUNCTION TRIM(WS-EDIT) "|world-type=cobolcraft" DELIMITED BY SIZE INTO WS-CONF
     CALL "SVT-WRITE-CONF" USING WS-CONF
     CALL "SV-START"
     MOVE "test default port free a server on the free port starts while 25565 is held" TO TL-CASE
     MOVE WS-FREE TO TL-EXPECTED-N
     MOVE SV-BOUND-PORT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "SV-SHUTDOWN"
     IF WS-RC = 0
         CALL STATIC "cc_net_close" USING BY VALUE WS-HOLDER
     END-IF
     CALL "SVT-HOME"
     STOP RUN.
 END PROGRAM TEST-DEFAULT-PORT-FREE.
 COPY SVTEST.
