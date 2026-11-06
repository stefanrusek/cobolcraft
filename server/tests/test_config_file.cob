*> Implementation test of the configuration file (server/src/config-file.cob; operator-surface §2,
*> FR-012, research R14): the limits of each value are accepted; a later line of a key wins; keys
*> are trimmed and a carriage return ends a line; a default file that cannot be written is one
*> ERROR line and the defaults are used; a file that exists but cannot be read is fatal (checked
*> in a forked child, SVT-FORK). Runs in build/server-test-config-file*.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CONFIG-FILE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY COREAPI.
 COPY TESTLIB.
 01 WS-SCRATCH             PIC X(256).
 01 WS-CONF                PIC X(4096).
 01 WS-CAPTURE             PIC X(256) VALUE "../stdout-config-file.txt".
 01 WS-CAPTURED            PIC X(4096).
 01 WS-PORT                BINARY-LONG.
 01 WS-PID                 BINARY-LONG.
 01 WS-EXIT                BINARY-LONG.
 01 WS-STDERR              PIC X(4096).
 01 WS-EDIT                PIC -(9)9.
 01 WS-EDIT2               PIC -(9)9.
 01 WS-LONGEST             PIC X(256).
 01 WS-COMMAND             PIC X(256).
 PROCEDURE DIVISION.
     MOVE "build/server-test-config-file" TO WS-SCRATCH
     CALL "SVT-SCRATCH" USING WS-SCRATCH

*>   The upper limits; a later line of a key wins; a description of exactly 256 characters.
     MOVE ALL "d" TO WS-LONGEST
     MOVE SPACES TO WS-CONF
     STRING "port=65535|view-distance=32|default-game-mode=survival|default-game-mode=creative|d"
         "escription=" WS-LONGEST DELIMITED BY SIZE INTO WS-CONF
     CALL "SVT-WRITE-CONF" USING WS-CONF
     CALL "SV-CONFIG-LOAD" USING CORE-SETTINGS WS-PORT
     MOVE "test config file the upper limits are accepted and a later line of a key wins" TO TL-CASE
     PERFORM SUMMARIZE
     MOVE "port 65535 view 32 mode 1 description 256" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The lower limits; keys trimmed; carriage returns (a file written on Windows).
     MOVE SPACES TO WS-CONF
     STRING "  port =1" X"0D" "|view-distance=2" X"0D" "|description=" X"0D" "|  default-game"
         "-mode  =survival" DELIMITED BY SIZE INTO WS-CONF
     CALL "SVT-WRITE-CONF" USING WS-CONF
     CALL "SV-CONFIG-LOAD" USING CORE-SETTINGS WS-PORT
     MOVE "test config file the lower limits are accepted, keys are trimmed and a carriage return "
         & "ends a line" TO TL-CASE
     PERFORM SUMMARIZE
     MOVE "port 1 view 2 mode 0 description 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   No file, and the folder cannot be written: one ERROR line, the defaults are used.
     CALL "SVT-HOME"
     MOVE "build/server-test-config-file-ro" TO WS-SCRATCH
     CALL "SVT-SCRATCH" USING WS-SCRATCH
     MOVE "chmod 555 ." TO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     CALL "SVT-CAPTURE-START" USING WS-CAPTURE
     CALL "SV-CONFIG-LOAD" USING CORE-SETTINGS WS-PORT
     CALL "SVT-CAPTURE-STOP" USING WS-CAPTURE WS-CAPTURED
     CALL "SVT-UNSTAMP" USING WS-CAPTURED
     MOVE "chmod 755 ." TO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     MOVE 0 TO RETURN-CODE
     MOVE "test config file a default file that cannot be written is one ERROR line and the "
         & "defaults are used" TO TL-CASE
     PERFORM SUMMARIZE
     STRING FUNCTION TRIM(TL-OBSERVED) " | " FUNCTION TRIM(WS-CAPTURED) DELIMITED BY SIZE
         INTO TL-OBSERVED
     MOVE "port 25565 view 8 mode 1 description 19 | ERROR configuration: cannot write cobolcraf"
         & "t-server.conf" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A file that exists but cannot be read is fatal.
     MOVE "port=25565" TO WS-CONF
     CALL "SVT-WRITE-CONF" USING WS-CONF
     MOVE "chmod 000 cobolcraft-server.conf" TO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     MOVE 0 TO RETURN-CODE
     CALL "SVT-FORK" USING WS-PID
     IF WS-PID = 0
         CALL "SV-CONFIG-LOAD" USING CORE-SETTINGS WS-PORT
         STOP RUN
     END-IF
     CALL "SVT-WAIT" USING WS-PID WS-EXIT WS-STDERR
     MOVE "test config file a file that cannot be read is fatal" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "exit 1 FATAL configuration: cobolcraft-server.conf: cannot be read (file status 37)"
         TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-EXIT TO WS-EDIT
     STRING "exit " FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-STDERR) DELIMITED BY SIZE
         INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "SVT-HOME"
     STOP RUN.

 SUMMARIZE.
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-PORT TO WS-EDIT
     MOVE CS-VIEW-DISTANCE TO WS-EDIT2
     STRING "port " FUNCTION TRIM(WS-EDIT) " view " FUNCTION TRIM(WS-EDIT2) " mode "
         CS-DEFAULT-MODE DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE FUNCTION LENGTH(FUNCTION TRIM(CS-DESCRIPTION TRAILING)) TO WS-EDIT
     IF CS-DESCRIPTION = SPACES
         MOVE 0 TO WS-EDIT
     END-IF
     STRING FUNCTION TRIM(TL-OBSERVED) " description " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE
         INTO TL-OBSERVED.
 END PROGRAM TEST-CONFIG-FILE.
 COPY SVTEST.
