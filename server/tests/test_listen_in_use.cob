*> Fatal-path test of TCP-LISTEN (server/src/tcp-host.cob; FR-012, research R14): when the port is
*> already in use the server cannot serve, so it ends with "FATAL listen: port <n> is already in
*> use" and exit status 1 (test_listen_in_use.expect).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-LISTEN-IN-USE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY SVSTATE.
 01 WS-PORT-ZERO           BINARY-LONG VALUE 0.
 01 WS-PORT                BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TCP-LISTEN" USING WS-PORT-ZERO
     MOVE SV-BOUND-PORT TO WS-PORT
     CALL "TCP-LISTEN" USING WS-PORT
     STOP RUN.
 END PROGRAM TEST-LISTEN-IN-USE.
