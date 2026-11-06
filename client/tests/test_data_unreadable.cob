*> Fatal-path test of client/src/game-dir.cob (research R14: a saved client data file that cannot be
*> read is fatal): a servers.dat that is not gzip NBT ends the client with "FATAL client data: ..."
*> and exit status 1 (.expect).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-DATA-UNREADABLE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION.
     CALL "SYSTEM" USING "rm -rf build/client-test-unreadable"
     CALL "CL-INIT" USING CLIENT-STATE
     MOVE "build/client-test-unreadable" TO CL-GAME-DIR
     MOVE 28 TO CL-GAME-DIR-LENGTH
     CALL "GAME-DIR-SETUP" USING CLIENT-STATE
     CALL "SYSTEM" USING "echo not-nbt > build/client-test-unreadable/servers.dat"
     CALL "SERVERS-LOAD" USING CLIENT-STATE
     DISPLAY "not reached"
     STOP RUN.
 END PROGRAM TEST-DATA-UNREADABLE.
