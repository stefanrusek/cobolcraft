*> Implementation test of client/src/game-dir.cob (GAME-DIR-SETUP; contracts/client-surface.md §2):
*> the game directory, with any missing parent, and its resourcepacks/, saves/ and downloads/
*> directories are created when absent; set-up of an existing directory changes nothing.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-GAME-DIR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/client-test-gamedir/nested/dir".
 01 WS-PATH                PIC X(256).
 01 WS-INFO                PIC X(16).
 01 WS-I                   BINARY-LONG.
 01 WS-NAMES.
    05 FILLER PIC X(16) VALUE SPACES.
    05 FILLER PIC X(16) VALUE "/resourcepacks".
    05 FILLER PIC X(16) VALUE "/saves".
    05 FILLER PIC X(16) VALUE "/downloads".
 01 WS-NAME-TABLE REDEFINES WS-NAMES.
    05 WS-NAME             PIC X(16) OCCURS 4 TIMES.
 PROCEDURE DIVISION.
     CALL "SYSTEM" USING "rm -rf build/client-test-gamedir"
     CALL "CL-INIT" USING CLIENT-STATE
     MOVE WS-DIR TO CL-GAME-DIR
     MOVE 36 TO CL-GAME-DIR-LENGTH
     CALL "GAME-DIR-SETUP" USING CLIENT-STATE
     CALL "GAME-DIR-SETUP" USING CLIENT-STATE
     MOVE "T" TO TL-MODE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         MOVE SPACES TO TL-CASE WS-PATH
         STRING "game dir set-up creates " FUNCTION TRIM(WS-DIR) WS-NAME(WS-I)
             DELIMITED BY SIZE INTO TL-CASE
         STRING FUNCTION TRIM(WS-DIR) WS-NAME(WS-I) DELIMITED BY SPACE INTO WS-PATH
         CALL "CBL_CHECK_FILE_EXIST" USING WS-PATH WS-INFO
         MOVE "exists" TO TL-EXPECTED
         MOVE "absent" TO TL-OBSERVED
         IF RETURN-CODE = 0
             MOVE "exists" TO TL-OBSERVED
         END-IF
         MOVE 0 TO RETURN-CODE
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     STOP RUN.
 END PROGRAM TEST-GAME-DIR.
