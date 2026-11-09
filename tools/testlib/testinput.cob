*> TEST-INPUT-PATH: resolves a real test input (contracts/test-harness-delta.md "Test inputs").
*> The path is $COBOLCRAFT_INPUTS/<name> when that variable is set and non-empty, else tmp/<name>
*> (relative to the repository root, where every test runs). A missing file is a loud failure, never a
*> skip: the program prints
*>   TEST <case> FAIL expected=file observed=missing <path>
*> and ends the run with status 1. Test infrastructure (excluded from coverage).
*> CALL "TEST-INPUT-PATH" USING case-name(X(240)) file-name(X(256)) path(X(1024)).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-INPUT-PATH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DIRECTORY       PIC X(1024).
 01 WS-FILE-INFO       PIC X(16).
 01 WS-STATUS          BINARY-LONG.
 LINKAGE SECTION.
 01 LS-CASE            PIC X(240).
 01 LS-NAME            PIC X(256).
 01 LS-PATH            PIC X(1024).
 PROCEDURE DIVISION USING LS-CASE LS-NAME LS-PATH.
     MOVE SPACES TO WS-DIRECTORY
     ACCEPT WS-DIRECTORY FROM ENVIRONMENT "COBOLCRAFT_INPUTS"
         ON EXCEPTION
             MOVE SPACES TO WS-DIRECTORY
     END-ACCEPT
     MOVE SPACES TO LS-PATH
     IF WS-DIRECTORY = SPACES
         STRING "tmp/" FUNCTION TRIM(LS-NAME TRAILING)
             DELIMITED BY SIZE INTO LS-PATH
     ELSE
         STRING FUNCTION TRIM(WS-DIRECTORY TRAILING) "/" FUNCTION TRIM(LS-NAME TRAILING)
             DELIMITED BY SIZE INTO LS-PATH
     END-IF
     CALL "CBL_CHECK_FILE_EXIST" USING LS-PATH WS-FILE-INFO
         RETURNING WS-STATUS
     IF WS-STATUS NOT = 0
         DISPLAY "TEST " FUNCTION TRIM(LS-CASE TRAILING)
                 " FAIL expected=file observed=missing "
                 FUNCTION TRIM(LS-PATH TRAILING)
         STOP RUN RETURNING 1
     END-IF
     GOBACK.
 END PROGRAM TEST-INPUT-PATH.
