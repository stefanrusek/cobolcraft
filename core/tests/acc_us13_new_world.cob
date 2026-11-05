*> Acceptance test, US13-1 core half (spec US13 scenario 1; tasks T615; core-host-api §2
*> CORE-WORLD-OPEN; 07 §9.1, §9.5): given no world folder, when the world is opened, then a new
*> world folder is created (with players/ and each enabled dimension's region/ and entities/
*> folders) and the created flag is 1. The console lines are the server's (US13-server).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US13-NEW-WORLD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY COREAPI.
 01 WS-CLEAR               PIC X(64) VALUE "rm -rf build/core-test-new-world".
 01 WS-PATH                PIC X(64) VALUE Z"build/core-test-new-world".
 01 WS-CREATED             BINARY-LONG.
 01 WS-INFO                PIC X(16).
 01 WS-NAME                PIC X(128).
 01 WS-EDIT                PIC -(9)9.
 01 WS-I                   BINARY-LONG.
 01 WS-NAMES.
    05 FILLER PIC X(80) VALUE "build/core-test-new-world".
    05 FILLER PIC X(80) VALUE "build/core-test-new-world/players".
    05 FILLER PIC X(80) VALUE "build/core-test-new-world/dimensions/cobolcraft/main/region".
    05 FILLER PIC X(80) VALUE "build/core-test-new-world/dimensions/cobolcraft/main/entities".
    05 FILLER PIC X(80) VALUE "build/core-test-new-world/dimensions/cobolcraft/subroutine/region".
 01 WS-NAME-TABLE REDEFINES WS-NAMES.
    05 WS-FOLDER           PIC X(80) OCCURS 5 TIMES.
 PROCEDURE DIVISION.
     MOVE "acceptance US13-1 given no world folder when the world is opened then a new world "
         & "folder is created and the created flag is 1" TO TL-CASE
     CALL "SYSTEM" USING WS-CLEAR
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 1 TO CS-EXTRA-DIMENSIONS
     CALL "CORE-WORLD-OPEN" USING WS-PATH CORE-SETTINGS WS-CREATED
     MOVE "T" TO TL-MODE
     MOVE "created 1 folders 1 1 1 1 1" TO TL-EXPECTED
     MOVE WS-CREATED TO WS-EDIT
     MOVE SPACES TO TL-OBSERVED
     STRING "created " FUNCTION TRIM(WS-EDIT) " folders" DELIMITED BY SIZE INTO TL-OBSERVED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         MOVE WS-FOLDER(WS-I) TO WS-NAME
         CALL "CBL_CHECK_FILE_EXIST" USING WS-NAME WS-INFO
         IF RETURN-CODE = 0
             STRING FUNCTION TRIM(TL-OBSERVED) " 1" DELIMITED BY SIZE INTO TL-OBSERVED
         ELSE
             STRING FUNCTION TRIM(TL-OBSERVED) " 0" DELIMITED BY SIZE INTO TL-OBSERVED
         END-IF
     END-PERFORM
     MOVE 0 TO RETURN-CODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-US13-NEW-WORLD.

 COPY CORETEST.
