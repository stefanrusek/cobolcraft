*> Acceptance test US1-3 / US1-4 (docs/protocol/22-extraction-tool.md section 9.2; world-types.md section 3.5): at
*> start-up the server checks the generated packs. For each of the five statuses a cobolcraft world still starts
*> (the ready line is printed); with a status other than ok the console says "Standard worlds are unavailable: "
*> and the 22 section 9.2 text; world-type auto that creates a cobolcraft world for a missing pack prints the
*> auto_fallback line; reopening a cobolcraft world with packs not ok prints the unavailable line again.
*> Generated directories are the contract/fixtures/content trees. Runs in build/server-test-packs.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US1-STARTUP-PACKS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-SCRATCH             PIC X(256) VALUE "build/server-test-packs".
 01 WS-CONF                PIC X(4096).
 01 WS-CAPTURE             PIC X(256) VALUE "stdout.txt".
 01 WS-CAPTURED            PIC X(4096).
 01 WS-I                   BINARY-LONG.
 01 WS-EXPECT              PIC X(512).
 01 WS-CASES.
    05 FILLER PIC X(32) VALUE "valid".
    05 FILLER PIC X(200) VALUE " ".
    05 FILLER PIC X(32) VALUE "no-such-dir".
    05 FILLER PIC X(200) VALUE "Standard worlds are unavailable: Minecraft content is not set up. Run the extraction tool with your Minecraft 26.3 client jar to play standard worlds. | ".
    05 FILLER PIC X(32) VALUE "incomplete".
    05 FILLER PIC X(200) VALUE "Standard worlds are unavailable: The Minecraft content is incomplete. Run the extraction tool again. | ".
    05 FILLER PIC X(32) VALUE "stale".
    05 FILLER PIC X(200) VALUE "Standard worlds are unavailable: The Minecraft content was made for another version. Run the extraction tool again. | ".
    05 FILLER PIC X(32) VALUE "damaged".
    05 FILLER PIC X(200) VALUE "Standard worlds are unavailable: The Minecraft content is damaged. Run the extraction tool with --force. | ".
 01 WS-CASE-TABLE REDEFINES WS-CASES.
    05 WS-CASE OCCURS 5 TIMES.
       10 WS-DIR           PIC X(32).
       10 WS-NOTICE        PIC X(200).
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         CALL "SVT-HOME"
         CALL "SVT-SCRATCH" USING WS-SCRATCH
         MOVE SPACES TO WS-CONF
         STRING "port=25581|world-type=cobolcraft|generated-dir=../../contract/fixtures/content/"
             FUNCTION TRIM(WS-DIR(WS-I)) DELIMITED BY SIZE INTO WS-CONF
         CALL "SVT-WRITE-CONF" USING WS-CONF
         CALL "SVT-CAPTURE-START" USING WS-CAPTURE
         CALL "SV-START"
         CALL "SVT-CAPTURE-STOP" USING WS-CAPTURE WS-CAPTURED
         CALL "SVT-UNSTAMP" USING WS-CAPTURED
         MOVE SPACES TO TL-CASE TL-EXPECTED
         STRING "acceptance US1-3 given packs " FUNCTION TRIM(WS-DIR(WS-I)) " when a cobolcraft server starts then it prints "
             "the packs status and still starts" DELIMITED BY SIZE INTO TL-CASE
         MOVE SPACES TO WS-EXPECT
         IF WS-NOTICE(WS-I) = SPACES
             MOVE "Created new world in ./world | Ready: accepting players on 0.0.0.0:25581" TO WS-EXPECT
         ELSE
             STRING FUNCTION TRIM(WS-NOTICE(WS-I)) " Created new world in ./world | Ready: accepting players on "
                 "0.0.0.0:25581" DELIMITED BY SIZE INTO WS-EXPECT
         END-IF
         MOVE WS-EXPECT TO TL-EXPECTED
         MOVE WS-CAPTURED TO TL-OBSERVED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         CALL "SV-SHUTDOWN"
     END-PERFORM

*>   world-type auto with no packs creates a cobolcraft world and says so.
     CALL "SVT-HOME"
     CALL "SVT-SCRATCH" USING WS-SCRATCH
     MOVE "port=25581|generated-dir=../../contract/fixtures/content/stale" TO WS-CONF
     CALL "SVT-WRITE-CONF" USING WS-CONF
     CALL "SVT-CAPTURE-START" USING WS-CAPTURE
     CALL "SV-START"
     CALL "SVT-CAPTURE-STOP" USING WS-CAPTURE WS-CAPTURED
     CALL "SVT-UNSTAMP" USING WS-CAPTURED
     MOVE "acceptance US1-4 given world-type auto and stale packs when the server creates a world then it is cobolcraft "
         & "and the auto_fallback line says why" TO TL-CASE
     MOVE "world-type=auto: Minecraft content is not usable (stale), created a cobolcraft world | Created new world in ./world "
         & "| Ready: accepting players on 0.0.0.0:25581" TO TL-EXPECTED
     MOVE WS-CAPTURED TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "CORE-SAVE"
     CALL "SV-SHUTDOWN"

*>   Reopening that cobolcraft world: the unavailable line (auto prints no fallback line for an existing world).
     CALL "SVT-CAPTURE-START" USING WS-CAPTURE
     CALL "SV-START"
     CALL "SVT-CAPTURE-STOP" USING WS-CAPTURE WS-CAPTURED
     CALL "SVT-UNSTAMP" USING WS-CAPTURED
     MOVE "acceptance US1-4 given a cobolcraft world and stale packs when the server starts again then the unavailable line "
         & "is printed and the world opens" TO TL-CASE
     MOVE "Standard worlds are unavailable: The Minecraft content was made for another version. Run the extraction tool again. "
         & "| Ready: accepting players on 0.0.0.0:25581" TO TL-EXPECTED
     MOVE WS-CAPTURED TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "SV-SHUTDOWN"
     CALL "SVT-HOME"
     STOP RUN.
 END PROGRAM ACC-F2US1-STARTUP-PACKS.
 COPY SVTEST.
