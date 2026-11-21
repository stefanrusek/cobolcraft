*> Implementation test (T0450; docs/design/world-types.md section 2.1, docs/design/debug-world.md): the hidden debug type at the open of a world.
*> A new world requested as debug opens the content set of the standard type, so with the packs not ok it is refused with the packs status
*> (-1 in the created flag, the world not open, WORLD-CONTENT-OPEN answers CORE-WO-PACKS-NOT-OK for debug as for standard and CORE-WO-OK for
*> cobolcraft). A world saved with the type debug records WorldType = debug in level.dat (LEVEL-PEEK-TYPE reads it back) and a reopen of the
*> folder decides debug whatever type is requested (WORLD-TYPE-DECIDE). The packs-ok open of a standard set cannot be made over the fixture
*> trees (acc_f2us2_world_type), so the success path is asserted at the level.dat and the decision.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-DEBUG-OPEN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 01 WS-FOLDER              PIC X(64) VALUE Z"build/debug-open-folder".
 01 WS-COMMAND             PIC X(200).
 01 WS-CREATED             BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-TEXT                PIC X(32).
 01 WS-TYPE                PIC X(10).
 01 WS-REQUEST             PIC X(10).
 01 WS-DIR                 PIC X(1024).
 01 WS-EDIT                PIC -(9)9.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     MOVE "rm -rf build/debug-open-folder && mkdir -p build/debug-open-folder" TO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "debug" TO CS-WORLD-TYPE
     MOVE "build/no-such-generated-dir" TO CS-GENERATED-DIR
     CALL "CORE-WORLD-OPEN" USING WS-FOLDER CORE-SETTINGS WS-CREATED
     MOVE "test debug open a new debug world with the packs not ok is refused -1 and is not open" TO TL-CASE
     MOVE WS-CREATED TO WS-EDIT
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-EDIT) " " CW-OPEN DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "-1 N" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "build/no-such-generated-dir" TO WS-DIR
     MOVE "debug" TO WS-TYPE
     CALL "WORLD-CONTENT-OPEN" USING WS-TYPE WS-DIR WS-STATUS
     MOVE "test debug open the content set of debug is the standard set: packs not ok gives the packs status" TO TL-CASE
     MOVE WS-STATUS TO TL-OBSERVED-N
     MOVE CORE-WO-PACKS-NOT-OK TO TL-EXPECTED-N
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "cobolcraft" TO WS-TYPE
     CALL "WORLD-CONTENT-OPEN" USING WS-TYPE WS-DIR WS-STATUS
     MOVE "test debug open the cobolcraft set opens whatever the generated directory" TO TL-CASE
     MOVE WS-STATUS TO TL-OBSERVED-N
     MOVE CORE-WO-OK TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   a world saved as debug records it and reopens as debug
     MOVE "rm -rf build/debug-open-folder && mkdir -p build/debug-open-folder" TO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "CORE-WORLD-OPEN" USING WS-FOLDER CORE-SETTINGS WS-CREATED
     MOVE "debug" TO CW-WORLD-TYPE
     CALL "CORE-SAVE"
     CALL "LEVEL-PEEK-TYPE" USING WS-FOUND WS-TEXT
     MOVE "test debug open level.dat of a world saved as debug holds WorldType = debug" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-FOUND TO WS-EDIT
     STRING FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-TEXT) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "1 debug" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "standard" TO WS-REQUEST
     CALL "WORLD-TYPE-DECIDE" USING WS-REQUEST WS-TYPE WS-STATUS
     MOVE "test debug open a reopen of the folder decides debug whatever type is requested" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-STATUS TO WS-EDIT
     STRING FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-TYPE) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "0 debug" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-DEBUG-OPEN.
 COPY CORETEST.
