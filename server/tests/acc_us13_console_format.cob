*> Acceptance test, US13-3 server half: the console line format (contracts/operator-surface.md §3).
*> Every printed line, the drained console lines and the program's own lines alike, starts with the
*> local time as "[HH:MM:SS] ". Runs in build/server-test-console-format.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US13-CONSOLE-FORMAT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-SCRATCH             PIC X(256) VALUE "build/server-test-console-format".
 01 WS-CONF                PIC X(4096) VALUE "port=25575".
 01 WS-CAPTURE             PIC X(256) VALUE "stdout.txt".
 01 WS-CAPTURED            PIC X(4096).
 01 WS-COMMAND             PIC X(64) VALUE Z"nosuchcommand".
 01 WS-BEFORE              PIC X(21).
 01 WS-AFTER               PIC X(21).
 01 WS-STAMP-BEFORE        PIC X(11).
 01 WS-STAMP-AFTER         PIC X(11).
 PROCEDURE DIVISION.
     CALL "SVT-SCRATCH" USING WS-SCRATCH
     CALL "SVT-WRITE-CONF" USING WS-CONF
     MOVE FUNCTION CURRENT-DATE TO WS-BEFORE
     CALL "SVT-CAPTURE-START" USING WS-CAPTURE
     CALL "SV-START"
     CALL "SVT-CAPTURE-STOP" USING WS-CAPTURE WS-CAPTURED
     MOVE FUNCTION CURRENT-DATE TO WS-AFTER
     PERFORM STAMPS
     MOVE "acceptance US13-3 the server's own lines are printed with the [HH:MM:SS] prefix"
         TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-EXPECTED
     STRING WS-STAMP-BEFORE "Created new world in ./world | " WS-STAMP-BEFORE
         "Ready: accepting players on 0.0.0.0:25575" DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE WS-CAPTURED TO TL-OBSERVED
     IF WS-STAMP-AFTER NOT = WS-STAMP-BEFORE
         INSPECT TL-OBSERVED REPLACING ALL WS-STAMP-AFTER BY WS-STAMP-BEFORE
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "CORE-CONSOLE" USING WS-COMMAND
     MOVE FUNCTION CURRENT-DATE TO WS-BEFORE
     CALL "SVT-CAPTURE-START" USING WS-CAPTURE
     CALL "SV-ITERATE"
     CALL "SVT-CAPTURE-STOP" USING WS-CAPTURE WS-CAPTURED
     MOVE FUNCTION CURRENT-DATE TO WS-AFTER
     PERFORM STAMPS
     MOVE "acceptance US13-3 drained console lines are printed with the [HH:MM:SS] prefix"
         TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     STRING WS-STAMP-BEFORE "Unknown command nosuchcommand (howto lists the commands)"
         DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE WS-CAPTURED TO TL-OBSERVED
     IF WS-STAMP-AFTER NOT = WS-STAMP-BEFORE
         INSPECT TL-OBSERVED REPLACING ALL WS-STAMP-AFTER BY WS-STAMP-BEFORE
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "SV-SHUTDOWN"
     CALL "SVT-HOME"
     STOP RUN.

*>   The stamps of the local time just before and just after: the printed one is either.
 STAMPS.
     MOVE SPACES TO WS-STAMP-BEFORE WS-STAMP-AFTER
     STRING "[" WS-BEFORE(9:2) ":" WS-BEFORE(11:2) ":" WS-BEFORE(13:2) "] " DELIMITED BY SIZE
         INTO WS-STAMP-BEFORE
     STRING "[" WS-AFTER(9:2) ":" WS-AFTER(11:2) ":" WS-AFTER(13:2) "] " DELIMITED BY SIZE
         INTO WS-STAMP-AFTER.
 END PROGRAM ACC-US13-CONSOLE-FORMAT.
 COPY SVTEST.
