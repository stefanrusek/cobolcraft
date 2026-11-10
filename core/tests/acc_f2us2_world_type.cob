*> Acceptance test US2-1 / US2-3 (T0333; docs/design/world-types.md section 2.1, WT-24; FR-004): a new world records its
*> type and reopening yields the same type; a standard world whose packs are not ok is refused with a status word
*> (-1 in the created flag, the world not open); an old world of feature 001 (no WorldType, no dimensions/minecraft)
*> opens as cobolcraft; a folder with dimensions/ and no level.dat, or with dimensions/minecraft and no WorldType,
*> or with a WorldType of another value or tag type, is refused (-2, -3). The standard set cannot be opened over the
*> fixture trees (they give CT-BAD-DATA), so only its refusal is asserted.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US2-WORLD-TYPE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WS-FOLDER              PIC X(64) VALUE Z"build/wt-folder".
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-LENGTH         BINARY-LONG.
 01 WS-COMMAND             PIC X(200).
 01 WS-CREATED             BINARY-LONG.
 01 WS-OBSERVED            PIC X(200).
 01 WS-EDIT                PIC -(9)9.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-LONG                BINARY-DOUBLE.
 01 WS-INT                 BINARY-LONG.
 01 WS-KIND                PIC 9.
 PROCEDURE DIVISION.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "T" TO TL-MODE

*>   A new standard world over a generated directory that does not exist: refused with the packs status.
     PERFORM FRESH-FOLDER
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE "build/no-such-generated-dir" TO CS-GENERATED-DIR
     CALL "CORE-WORLD-OPEN" USING WS-FOLDER CORE-SETTINGS WS-CREATED
     MOVE "acceptance US2-1 given a standard world and packs not ok when it is created then it is refused -1 and is not open"
         TO TL-CASE
     MOVE WS-CREATED TO WS-EDIT
     MOVE SPACES TO WS-OBSERVED
     STRING FUNCTION TRIM(WS-EDIT) " " CW-OPEN DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE "-1 N" TO TL-EXPECTED
     PERFORM CHECK

*>   A new cobolcraft world records its type; reopening yields the same type.
     PERFORM FRESH-FOLDER
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE SPACES TO CS-WORLD-TYPE
     CALL "CORE-WORLD-OPEN" USING WS-FOLDER CORE-SETTINGS WS-CREATED
     CALL "CORE-SAVE"
     MOVE SPACES TO WS-OBSERVED
     MOVE WS-CREATED TO WS-EDIT
     STRING FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(CW-WORLD-TYPE) DELIMITED BY SIZE INTO WS-OBSERVED
     CALL "CORE-WORLD-OPEN" USING WS-FOLDER CORE-SETTINGS WS-CREATED
     MOVE WS-CREATED TO WS-EDIT
     STRING FUNCTION TRIM(WS-OBSERVED) " " FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(CW-WORLD-TYPE)
         DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE "acceptance US2-1 given a new world with no type requested when it is saved and reopened then it is cobolcraft both times"
         TO TL-CASE
     MOVE "1 cobolcraft 0 cobolcraft" TO TL-EXPECTED
     PERFORM CHECK

*>   An old world of feature 001: level.dat without WorldType, no dimensions/minecraft: cobolcraft (rule 2).
     PERFORM FRESH-FOLDER
     CALL "CORE-WORLD-OPEN" USING WS-FOLDER CORE-SETTINGS WS-CREATED
     CALL "CORE-SAVE"
     PERFORM WRITE-LEVEL-WITHOUT-TYPE
     CALL "CORE-WORLD-OPEN" USING WS-FOLDER CORE-SETTINGS WS-CREATED
     MOVE WS-CREATED TO WS-EDIT
     MOVE SPACES TO WS-OBSERVED
     STRING FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(CW-WORLD-TYPE) DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE "acceptance US2-3 given an old world with no WorldType and no dimensions/minecraft when it opens then it is cobolcraft"
         TO TL-CASE
     MOVE "0 cobolcraft" TO TL-EXPECTED
     PERFORM CHECK

*>   Saved chunks (a region file) and no level.dat: -2 (WT-24); an empty folder tree, as an unsaved open leaves, is no world.
     PERFORM FRESH-FOLDER
     MOVE "mkdir -p build/wt-folder/dimensions/cobolcraft/main/region && touch build/wt-folder/dimensions/cobolcraft/main/region/r.0.0.mca"
         TO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     CALL "CORE-WORLD-OPEN" USING WS-FOLDER CORE-SETTINGS WS-CREATED
     MOVE WS-CREATED TO WS-EDIT
     MOVE "acceptance US2-3 given dimensions/ content and no level.dat when it is opened then it is refused -2"
         TO TL-CASE
     MOVE FUNCTION TRIM(WS-EDIT) TO WS-OBSERVED
     MOVE "-2" TO TL-EXPECTED
     PERFORM CHECK

*>   Standard dimension folders and no WorldType: -3.
     PERFORM FRESH-FOLDER
     MOVE "mkdir -p build/wt-folder/dimensions/minecraft/overworld/region" TO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     PERFORM WRITE-LEVEL-WITHOUT-TYPE
     CALL "CORE-WORLD-OPEN" USING WS-FOLDER CORE-SETTINGS WS-CREATED
     MOVE WS-CREATED TO WS-EDIT
     MOVE "acceptance US2-3 given standard dimension folders and no WorldType when it is opened then it is refused -3"
         TO TL-CASE
     MOVE FUNCTION TRIM(WS-EDIT) TO WS-OBSERVED
     MOVE "-3" TO TL-EXPECTED
     PERFORM CHECK

*>   A WorldType of another value ("Standard" is another string) and of another tag type: -3.
     PERFORM FRESH-FOLDER
     MOVE 1 TO WS-KIND
     PERFORM WRITE-LEVEL-WITH-TYPE
     CALL "CORE-WORLD-OPEN" USING WS-FOLDER CORE-SETTINGS WS-CREATED
     MOVE WS-CREATED TO WS-EDIT
     MOVE FUNCTION TRIM(WS-EDIT) TO WS-OBSERVED
     PERFORM FRESH-FOLDER
     MOVE 2 TO WS-KIND
     PERFORM WRITE-LEVEL-WITH-TYPE
     CALL "CORE-WORLD-OPEN" USING WS-FOLDER CORE-SETTINGS WS-CREATED
     MOVE WS-CREATED TO WS-EDIT
     STRING FUNCTION TRIM(WS-OBSERVED) " " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE "acceptance US2-3 given a WorldType Standard, and a WorldType of the wrong tag type when it opens then each is refused -3"
         TO TL-CASE
     MOVE "-3 -3" TO TL-EXPECTED
     PERFORM CHECK

*>   The hidden type debug opens the standard set: with the packs absent it is refused -1 like a standard world.
     PERFORM FRESH-FOLDER
     MOVE 3 TO WS-KIND
     PERFORM WRITE-LEVEL-WITH-TYPE
     MOVE "build/no-such-generated-dir" TO CS-GENERATED-DIR
     CALL "CORE-WORLD-OPEN" USING WS-FOLDER CORE-SETTINGS WS-CREATED
     MOVE WS-CREATED TO WS-EDIT
     MOVE "acceptance US2-3 given a world of the hidden type debug and packs not ok when it opens then it is refused -1"
         TO TL-CASE
     MOVE FUNCTION TRIM(WS-EDIT) TO WS-OBSERVED
     MOVE "-1" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

 FRESH-FOLDER.
     MOVE "rm -rf build/wt-folder && mkdir -p build/wt-folder" TO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND.

 WRITE-LEVEL-WITHOUT-TYPE.
     CALL "PB-RESET" USING PB-BUFFER
     MOVE SPACES TO WN
     MOVE 0 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "Time" TO WN MOVE 4 TO WL
     MOVE 6000 TO WS-LONG
     CALL "NBT-WRITE-LONG" USING PB-BUFFER WN WL WS-LONG
     PERFORM STORE-LEVEL.

 WRITE-LEVEL-WITH-TYPE.
     CALL "PB-RESET" USING PB-BUFFER
     MOVE SPACES TO WN
     MOVE 0 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "WorldType" TO WN MOVE 9 TO WL
     IF WS-KIND = 1
         MOVE 8 TO WS-LENGTH
         CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL "Standard" WS-LENGTH
     ELSE IF WS-KIND = 3
         MOVE 5 TO WS-LENGTH
         CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL "debug" WS-LENGTH
     ELSE
         MOVE 3 TO WS-INT
         CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-INT
     END-IF END-IF
     PERFORM STORE-LEVEL.

 STORE-LEVEL.
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE SPACES TO WS-FILE
     MOVE "build/wt-folder/level.dat" TO WS-FILE
     MOVE 25 TO WS-FILE-LENGTH
     CALL "PERSIST-WRITE-FILE" USING WS-FILE WS-FILE-LENGTH PB-BUFFER.

 CHECK.
     MOVE FUNCTION TRIM(WS-OBSERVED) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-F2US2-WORLD-TYPE.

 COPY CORETEST.
