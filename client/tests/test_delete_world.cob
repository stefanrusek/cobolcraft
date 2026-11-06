*> Implementation test of client/src/game-dir.cob WORLD-DELETE (US16-1): a world folder is deleted
*> with everything in it, however its subdirectories nest (cc_fs_list, CBL_DELETE_FILE,
*> CBL_DELETE_DIR), and its neighbours in saves/ are left alone; a folder nested deeper than 32
*> levels cannot be emptied: "ERROR world: <path> cannot be deleted" and the deletion stops.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-DELETE-WORLD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY TESTLIB.
 01 WS-FOLDER              PIC X(80).
 01 WS-FOLDER-LENGTH       BINARY-LONG.
 01 WS-PATH                PIC X(256).
 01 WS-INFO                PIC X(16).
 01 WS-DEEP                PIC X(512).
 01 WS-I                   BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-COMMAND             PIC X(1024).
 PROCEDURE DIVISION.
     CALL "SYSTEM" USING "rm -rf build/client-test-delete"
     CALL "CL-INIT" USING CLIENT-STATE
     MOVE "build/client-test-delete" TO CL-GAME-DIR
     MOVE 24 TO CL-GAME-DIR-LENGTH
     CALL "GAME-DIR-SETUP" USING CLIENT-STATE
     CALL "SYSTEM" USING "mkdir -p 'build/client-test-delete/saves/Old World/dimensions/"
         & "cobolcraft/main/region' 'build/client-test-delete/saves/Old World/dimensions/"
         & "cobolcraft/main/entities' 'build/client-test-delete/saves/Old World/players' "
         & "'build/client-test-delete/saves/Old World/empty' build/client-test-delete/saves/Other"
     CALL "SYSTEM" USING "cd 'build/client-test-delete/saves/Old World' && touch level.dat "
         & "access.dat players/a.dat dimensions/cobolcraft/main/region/r.0.0.mca "
         & "dimensions/cobolcraft/main/region/r.-1.0.mca dimensions/cobolcraft/main/entities/r.0.0.mca"
     CALL "SYSTEM" USING "touch build/client-test-delete/saves/Other/level.dat"
     MOVE "Old World" TO WS-FOLDER
     MOVE 9 TO WS-FOLDER-LENGTH
     CALL "WORLD-DELETE" USING CLIENT-STATE WS-FOLDER WS-FOLDER-LENGTH
     MOVE "delete world the folder, its files and nested directories are deleted; the next world "
         & "is untouched" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "old gone other kept" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE "build/client-test-delete/saves/Old World" TO WS-PATH
     CALL "CBL_CHECK_FILE_EXIST" USING WS-PATH WS-INFO
     IF RETURN-CODE = 0
         MOVE "old kept" TO TL-OBSERVED
     ELSE
         MOVE "old gone" TO TL-OBSERVED
     END-IF
     MOVE "build/client-test-delete/saves/Other/level.dat" TO WS-PATH
     CALL "CBL_CHECK_FILE_EXIST" USING WS-PATH WS-INFO
     IF RETURN-CODE = 0
         STRING FUNCTION TRIM(TL-OBSERVED) " other kept" DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     MOVE 0 TO RETURN-CODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   33 nested directories: the 33rd is never reached, so the 32nd cannot be deleted.
     MOVE SPACES TO WS-DEEP
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 33
         STRING "d/" DELIMITED BY SIZE INTO WS-DEEP WITH POINTER WS-PTR
     END-PERFORM
     MOVE LOW-VALUES TO WS-COMMAND
     STRING "mkdir -p build/client-test-delete/saves/Deep/" WS-DEEP(1:WS-PTR - 1)
         DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     MOVE "Deep" TO WS-FOLDER
     MOVE 4 TO WS-FOLDER-LENGTH
     CALL "WORLD-DELETE" USING CLIENT-STATE WS-FOLDER WS-FOLDER-LENGTH
     MOVE "delete world a folder deeper than 32 levels cannot be emptied: an ERROR line and the "
         & "deletion stops, the folder stays" TO TL-CASE
     MOVE "deep kept" TO TL-EXPECTED
     MOVE "build/client-test-delete/saves/Deep/d" TO WS-PATH
     MOVE "deep gone" TO TL-OBSERVED
     CALL "CBL_CHECK_FILE_EXIST" USING WS-PATH WS-INFO
     IF RETURN-CODE = 0
         MOVE "deep kept" TO TL-OBSERVED
     END-IF
     MOVE 0 TO RETURN-CODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-DELETE-WORLD.
 COPY CLTEST.
