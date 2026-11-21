*> Test of the generated-dir key (server/src/config-file.cob; specs/002-client-polish contracts/core-host-delta.md
*> section 1, 22 section 5.1): the default is <game directory>/generated (the server's game directory is "."), a value
*> fills CS-GENERATED-DIR, an empty value keeps the default, and a value over 1024 characters is fatal.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CONFIG-GENERATED-DIR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY COREAPI.
 COPY TESTLIB.
 01 WS-SCRATCH             PIC X(256) VALUE "build/server-test-config-gendir".
 01 WS-CONF                PIC X(4096).
 01 WS-PORT                BINARY-LONG.
 01 WS-PID                 BINARY-LONG.
 01 WS-EXIT                BINARY-LONG.
 01 WS-STDERR              PIC X(4096).
 PROCEDURE DIVISION.
     CALL "SVT-SCRATCH" USING WS-SCRATCH
     MOVE "port=25565" TO WS-CONF
     CALL "SVT-WRITE-CONF" USING WS-CONF
     CALL "SV-CONFIG-LOAD" USING CORE-SETTINGS WS-PORT
     MOVE "test config generated-dir missing key defaults to ./generated" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "./generated" TO TL-EXPECTED
     MOVE CS-GENERATED-DIR TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test config game dir is ." TO TL-CASE
     MOVE "." TO TL-EXPECTED
     MOVE CS-GAME-DIR TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "generated-dir=/tmp/gen dir" TO WS-CONF
     CALL "SVT-WRITE-CONF" USING WS-CONF
     CALL "SV-CONFIG-LOAD" USING CORE-SETTINGS WS-PORT
     MOVE "test config generated-dir value fills CS-GENERATED-DIR" TO TL-CASE
     MOVE "/tmp/gen dir" TO TL-EXPECTED
     MOVE CS-GENERATED-DIR TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "generated-dir=" TO WS-CONF
     CALL "SVT-WRITE-CONF" USING WS-CONF
     CALL "SV-CONFIG-LOAD" USING CORE-SETTINGS WS-PORT
     MOVE "test config generated-dir empty keeps the default" TO TL-CASE
     MOVE "./generated" TO TL-EXPECTED
     MOVE CS-GENERATED-DIR TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE SPACES TO WS-CONF
     MOVE "generated-dir=" TO WS-CONF
     MOVE ALL "d" TO WS-CONF(15:1025)
     CALL "SVT-WRITE-CONF" USING WS-CONF
     CALL "SVT-FORK" USING WS-PID
     IF WS-PID = 0
         CALL "SV-CONFIG-LOAD" USING CORE-SETTINGS WS-PORT
         STOP RUN
     END-IF
     CALL "SVT-WAIT" USING WS-PID WS-EXIT WS-STDERR
     MOVE "test config generated-dir of 1025 characters is fatal" TO TL-CASE
     MOVE "exit 1 FATAL configuration: generated-dir: longer than 1024 characters" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     IF WS-EXIT = 1
         STRING "exit 1 " FUNCTION TRIM(WS-STDERR) DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "SVT-HOME"
     STOP RUN.
 END PROGRAM TEST-CONFIG-GENERATED-DIR.
 COPY SVTEST.
