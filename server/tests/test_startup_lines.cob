*> Test (US21-server; specs/002-client-polish contracts/core-host-delta.md section 5): the start-up lines the manual
*> run of quickstart.md section 9 records. After the packs notice (if any) and before the created-world line the server
*> prints "World type: <type>", "Generated directory: <path>" and "Registries: <n> blocks, <n> block states, <n> items,
*> <n> entity types" (the open set's counts), and the ready line ends the start-up. The cobolcraft set has 13 blocks,
*> 19 block states, 19 items and 4 entity types (content acceptance test US2). Runs in build/server-test-startup.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STARTUP-LINES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-SCRATCH             PIC X(256) VALUE "build/server-test-startup".
 01 WS-CONF                PIC X(4096).
 01 WS-CAPTURE             PIC X(256) VALUE "stdout.txt".
 01 WS-CAPTURED            PIC X(4096).
 PROCEDURE DIVISION.
     CALL "SVT-SCRATCH" USING WS-SCRATCH
     MOVE "port=25583|world-type=cobolcraft|generated-dir=../../contract/fixtures/content/valid" TO WS-CONF
     CALL "SVT-WRITE-CONF" USING WS-CONF
     CALL "SVT-CAPTURE-START" USING WS-CAPTURE
     CALL "SV-START"
     CALL "SVT-CAPTURE-STOP" USING WS-CAPTURE WS-CAPTURED
     CALL "SVT-UNSTAMP" USING WS-CAPTURED
     MOVE "test startup lines a cobolcraft world prints its type, generated directory and registry counts before the "
         & "created and ready lines" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "World type: cobolcraft | Generated directory: ../../contract/fixtures/content/valid | Registries: 13 blocks, "
         & "19 block states, 19 items, 4 entity types | Created new world in ./world | Ready: accepting players on "
         & "0.0.0.0:25583" TO TL-EXPECTED
     MOVE WS-CAPTURED TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "CORE-SAVE"
     CALL "SV-SHUTDOWN"

*>   Reopened: the same three lines, no created-world line.
     CALL "SVT-CAPTURE-START" USING WS-CAPTURE
     CALL "SV-START"
     CALL "SVT-CAPTURE-STOP" USING WS-CAPTURE WS-CAPTURED
     CALL "SVT-UNSTAMP" USING WS-CAPTURED
     MOVE "test startup lines a reopened world prints the same lines without the created line" TO TL-CASE
     MOVE "World type: cobolcraft | Generated directory: ../../contract/fixtures/content/valid | Registries: 13 blocks, "
         & "19 block states, 19 items, 4 entity types | Ready: accepting players on 0.0.0.0:25583" TO TL-EXPECTED
     MOVE WS-CAPTURED TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "SV-SHUTDOWN"
     CALL "SVT-HOME"
     STOP RUN.
 END PROGRAM TEST-STARTUP-LINES.
 COPY SVTEST.
