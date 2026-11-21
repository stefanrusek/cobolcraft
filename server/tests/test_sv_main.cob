*> Test of SV-MAIN (server/src/loop.cob; contracts/test-harness.md §2; core-host-api.md §2): in a
*> scratch directory, SV-MAIN starts the server, iterates until the run state reaches 2 (the §16
*> stop command stop from test_sv_main.stdin), shuts down and ends the run with exit status 0
*> (test_sv_main.expect). SV-MAIN never returns: the line after it would end the run with 9.
*> Runs in build/server-test-sv-main.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SV-MAIN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SCRATCH             PIC X(256) VALUE "build/server-test-sv-main".
 01 WS-CONF                PIC X(4096) VALUE "port=25578".
 PROCEDURE DIVISION.
     CALL "SVT-SCRATCH" USING WS-SCRATCH
     CALL "SVT-WRITE-CONF" USING WS-CONF
     CALL "SV-MAIN"
     STOP RUN RETURNING 9.
 END PROGRAM TEST-SV-MAIN.
 COPY SVTEST.
