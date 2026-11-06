*> Fatal-path test (research R14; FR-012): CORE-WORLD-OPEN of a world folder whose level.dat cannot be
*> read (not gzip NBT) exits through cc_fatal naming the file (exit status 1 and the line
*> "FATAL world: cannot read build/core-test-unreadable/level.dat"; test_world_unreadable.expect).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-WORLD-UNREADABLE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY COREAPI.
 01 WS-COMMAND             PIC X(160).
 01 WS-PATH                PIC X(64) VALUE Z"build/core-test-unreadable".
 01 WS-CREATED             BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "rm -rf build/core-test-unreadable && mkdir -p build/core-test-unreadable && "
         & "echo not-nbt > build/core-test-unreadable/level.dat" TO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "CORE-WORLD-OPEN" USING WS-PATH CORE-SETTINGS WS-CREATED
     DISPLAY "TEST test world unreadable level.dat FAIL expected=fatal observed=created "
         WS-CREATED
     STOP RUN.
 END PROGRAM TEST-WORLD-UNREADABLE.

 COPY CORETEST.
