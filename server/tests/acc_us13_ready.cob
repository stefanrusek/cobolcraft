*> Acceptance test, US13-1 server half: the created-world and ready lines (contracts/
*> operator-surface.md §3). Given no world folder, starting shows "Created new world in ./world" and
*> "Ready: accepting players on 0.0.0.0:<port>"; given the saved world, only the ready line.
*> Runs in build/server-test-ready.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US13-READY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-SCRATCH             PIC X(256) VALUE "build/server-test-ready".
 01 WS-CONF                PIC X(4096) VALUE "port=25574".
 01 WS-CAPTURE             PIC X(256) VALUE "stdout.txt".
 01 WS-CAPTURED            PIC X(4096).
 PROCEDURE DIVISION.
     CALL "SVT-SCRATCH" USING WS-SCRATCH
     CALL "SVT-WRITE-CONF" USING WS-CONF
     CALL "SVT-CAPTURE-START" USING WS-CAPTURE
     CALL "SV-START"
     CALL "SVT-CAPTURE-STOP" USING WS-CAPTURE WS-CAPTURED
     CALL "SVT-UNSTAMP" USING WS-CAPTURED
     MOVE "acceptance US13-1 given no world folder when the server starts then the console shows "
         & "Created new world in ./world and Ready: accepting players on 0.0.0.0:<port>" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "Created new world in ./world | Ready: accepting players on 0.0.0.0:25574"
         TO TL-EXPECTED
     MOVE WS-CAPTURED TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "CORE-SAVE"
     CALL "SV-SHUTDOWN"

     CALL "SVT-CAPTURE-START" USING WS-CAPTURE
     CALL "SV-START"
     CALL "SVT-CAPTURE-STOP" USING WS-CAPTURE WS-CAPTURED
     CALL "SVT-UNSTAMP" USING WS-CAPTURED
     MOVE "acceptance US13-1 given the saved world when the server starts again then the console "
         & "shows only the ready line" TO TL-CASE
     MOVE "Ready: accepting players on 0.0.0.0:25574" TO TL-EXPECTED
     MOVE WS-CAPTURED TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "SV-SHUTDOWN"
     CALL "SVT-HOME"
     STOP RUN.
 END PROGRAM ACC-US13-READY.
 COPY SVTEST.
