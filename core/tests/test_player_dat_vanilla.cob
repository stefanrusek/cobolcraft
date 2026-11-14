*> Implementation test (vanfmt lane; docs/protocol/07 section 10.5): in a world opened in the 26.3 layout (CW-LAYOUT 1) the
*> player file is players/data/<uuid>.dat, and a file of CobolCraft's own place players/<uuid>.dat is still read when the
*> new place has none; in a world of the CobolCraft layout only players/<uuid>.dat is read or written.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PLAYER-DAT-VANILLA.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-ALICE-NAME          PIC X(16) VALUE "Alice".
 01 WS-LENGTH-5            BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-UUID                PIC X(16).
 01 WS-KNOWN               BINARY-LONG.
 01 WS-TEXT                PIC X(36).
 01 WS-COMMAND             PIC X(300).
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-INFO                PIC X(16).
 01 WS-FILE                PIC X(300).
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-JOIN" USING WS-ALICE-NAME WS-LENGTH-5 WS-ALICE
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW
     MOVE PL-UUID(WS-ROW) TO WS-UUID
     CALL "PERSIST-UUID-TEXT" USING WS-UUID WS-TEXT
*>   Layout 0: the file is players/<uuid>.dat, and players/data holds nothing.
     CALL "CORE-SAVE"
     MOVE SPACES TO WS-FILE
     STRING "build/core-test-world/players/" WS-TEXT ".dat" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-INFO
     MOVE RETURN-CODE TO WS-E1
     MOVE SPACES TO WS-FILE
     STRING "build/core-test-world/players/data/" WS-TEXT ".dat" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-INFO
     MOVE RETURN-CODE TO WS-E2
     MOVE "test player dat vanilla in the CobolCraft layout the save writes players/<uuid>.dat only" TO TL-CASE
     MOVE "0 nonzero" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     IF FUNCTION TRIM(WS-E2) NOT = "0"
         STRING FUNCTION TRIM(WS-E1) " nonzero" DELIMITED BY SIZE INTO TL-OBSERVED
     ELSE
         STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Layout 1: the next save writes players/data/<uuid>.dat.
     MOVE 1 TO CW-LAYOUT
     CALL "CORE-SAVE"
     MOVE SPACES TO WS-FILE
     STRING "build/core-test-world/players/data/" WS-TEXT ".dat" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-INFO
     MOVE RETURN-CODE TO WS-E1
     MOVE "test player dat vanilla in the 26.3 layout the save writes players/data/<uuid>.dat" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE FUNCTION TRIM(WS-E1) TO TL-OBSERVED
     MOVE "0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PLAYER-DAT-READ" USING WS-UUID WS-KNOWN
     MOVE "test player dat vanilla in the 26.3 layout the file of players/data is read" TO TL-CASE
     MOVE 0 TO WS-E1
     IF WS-KNOWN > 0
         MOVE 1 TO WS-E1
     END-IF
     MOVE FUNCTION TRIM(WS-E1) TO TL-OBSERVED
     MOVE "1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Only the old place has the file: still read in layout 1, not found when the layout is 0 and only players/data has it.
     MOVE "mv build/core-test-world/players/data build/core-test-world/players/moved" TO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     CALL "PLAYER-DAT-READ" USING WS-UUID WS-KNOWN
     MOVE "test player dat vanilla in the 26.3 layout a file at players/<uuid>.dat is still read" TO TL-CASE
     MOVE 0 TO WS-E1
     IF WS-KNOWN > 0
         MOVE 1 TO WS-E1
     END-IF
     MOVE FUNCTION TRIM(WS-E1) TO TL-OBSERVED
     MOVE "1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "rm build/core-test-world/players/*.dat; mv build/core-test-world/players/moved build/core-test-world/players/data" TO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     MOVE 0 TO CW-LAYOUT
     CALL "PLAYER-DAT-READ" USING WS-UUID WS-KNOWN
     MOVE "test player dat vanilla in the CobolCraft layout players/data is not read" TO TL-CASE
     MOVE 0 TO WS-E1
     IF WS-KNOWN > 0
         MOVE 1 TO WS-E1
     END-IF
     MOVE FUNCTION TRIM(WS-E1) TO TL-OBSERVED
     MOVE "0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-PLAYER-DAT-VANILLA.

 COPY CORETEST.
