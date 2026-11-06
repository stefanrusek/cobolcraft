*> Fatal-path test of the configuration parser (server/src/config-file.cob; operator-surface §2,
*> research R14): a key the configuration does not have ends the server with
*> "FATAL configuration: <key>: unknown key" and exit status 1 (test_config_unknown_key.expect).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CONFIG-UNKNOWN-KEY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY COREAPI.
 01 WS-SCRATCH             PIC X(256) VALUE "build/server-test-config-unknown".
 01 WS-CONF                PIC X(4096) VALUE "# a key the server does not have|port=25565|max-pl"
     & "ayers=20".
 01 WS-PORT                BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "SVT-SCRATCH" USING WS-SCRATCH
     CALL "SVT-WRITE-CONF" USING WS-CONF
     CALL "SV-CONFIG-LOAD" USING CORE-SETTINGS WS-PORT
     STOP RUN.
 END PROGRAM TEST-CONFIG-UNKNOWN-KEY.
 COPY SVTEST.
