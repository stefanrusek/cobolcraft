*> Fatal-path test (research R14; FR-012): a world save whose write fails exits through cc_fatal
*> naming the file. The world folder is replaced by a plain file after the world is opened, so
*> nothing can be written below it (exit status 1 and a line starting "FATAL world save: cannot
*> write build/core-test-save-fails/"; test_save_write_fails.expect).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SAVE-WRITE-FAILS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY COREAPI.
 01 WS-CLEAR               PIC X(64) VALUE "rm -rf build/core-test-save-fails".
 01 WS-BLOCK               PIC X(128).
 01 WS-PATH                PIC X(64) VALUE Z"build/core-test-save-fails".
 01 WS-CREATED             BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "SYSTEM" USING WS-CLEAR
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "CORE-WORLD-OPEN" USING WS-PATH CORE-SETTINGS WS-CREATED
     MOVE "rm -rf build/core-test-save-fails && echo x > build/core-test-save-fails" TO WS-BLOCK
     CALL "SYSTEM" USING WS-BLOCK
     CALL "CORE-SAVE"
     DISPLAY "TEST test save write fails FAIL expected=fatal observed=saved"
     STOP RUN.
 END PROGRAM TEST-SAVE-WRITE-FAILS.

 COPY CORETEST.
