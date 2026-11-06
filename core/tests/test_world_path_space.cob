*> Implementation test of the world-folder paths (core/src/persistence.cob, PERSIST-DIM-DIR and
*> PERSIST-DIRS; 07 §9.1): a world folder whose name contains a space ("New World", the client's
*> default single-player world name) is used whole, so the save writes below that folder and
*> creates dimensions/cobolcraft/main/region and entities there, not below a folder cut at the space.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-WORLD-PATH-SPACE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY COREAPI.
 01 WS-CLEAR               PIC X(80) VALUE
     "rm -rf 'build/core-test-spaced world' build/core-test-spaced".
 01 WS-PATH                PIC X(64) VALUE Z"build/core-test-spaced world".
 01 WS-CREATED             BINARY-LONG.
 01 WS-CHECK               PIC X(400).
 PROCEDURE DIVISION.
     CALL "SYSTEM" USING WS-CLEAR
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "CORE-WORLD-OPEN" USING WS-PATH CORE-SETTINGS WS-CREATED
     CALL "CORE-SAVE"

     MOVE "test world path space a world folder with a space in its name keeps its dimension "
         & "folders and level.dat below the whole name" TO TL-CASE
     SET TL-NUMBER TO TRUE
     MOVE 0 TO TL-EXPECTED-N
     MOVE "test -f 'build/core-test-spaced world/level.dat' "
         & "&& test -d 'build/core-test-spaced world/dimensions/cobolcraft/main/region' "
         & "&& test -d 'build/core-test-spaced world/dimensions/cobolcraft/main/entities' "
         & "&& test ! -e build/core-test-spaced" TO WS-CHECK
     CALL "SYSTEM" USING WS-CHECK
     MOVE RETURN-CODE TO TL-OBSERVED-N
     MOVE 0 TO RETURN-CODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "SYSTEM" USING WS-CLEAR
     MOVE 0 TO RETURN-CODE
     STOP RUN.
 END PROGRAM TEST-WORLD-PATH-SPACE.

 COPY CORETEST.
