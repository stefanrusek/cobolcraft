*> Fatal-path test of client/src/game-dir.cob (research R14: a file write that fails during save is
*> fatal): saving the server list into a game directory that cannot be written ends the client with
*> "FATAL client data: ..." and exit status 1 (.expect).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-DATA-UNWRITABLE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION.
     CALL "SYSTEM" USING "chmod -R u+w build/client-test-unwritable 2>/dev/null; rm -rf build/client-test-unwritable"
     CALL "CL-INIT" USING CLIENT-STATE
     MOVE "build/client-test-unwritable" TO CL-GAME-DIR
     MOVE 28 TO CL-GAME-DIR-LENGTH
     CALL "GAME-DIR-SETUP" USING CLIENT-STATE
     CALL "SYSTEM" USING "chmod a-w build/client-test-unwritable"
     CALL "SERVERS-SAVE" USING CLIENT-STATE
     DISPLAY "not reached"
     STOP RUN.
 END PROGRAM TEST-DATA-UNWRITABLE.
