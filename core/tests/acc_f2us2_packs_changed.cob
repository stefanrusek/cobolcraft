*> Edge-case acceptance test (T0335; world-types WT-6, WT-24; FR-003, FR-004, FR-005, FR-037; SC-011): a standard world
*> opened after its generated packs were deleted is refused (-1) with the absent reason; after they were rebuilt
*> (the valid fixture tree) the packs check is ok and the open is no longer refused for the packs: ContentJar of
*> level.dat is informational and is never compared. (The fixture tree gives CT-BAD-DATA at the registry load, so the
*> standard set itself cannot be opened here; CT-PACKS-STATUS is what is asserted.) A stale tree is refused with the
*> stale reason.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US2-PACKS-CHANGED.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WS-FOLDER              PIC X(64) VALUE Z"build/wt-packs".
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-LENGTH         BINARY-LONG.
 01 WS-COMMAND             PIC X(200).
 01 WS-CREATED             BINARY-LONG.
 01 WS-OBSERVED            PIC X(300).
 01 WS-EDIT                PIC -(9)9.
 01 WS-EDIT2               PIC -(9)9.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-LONG                BINARY-DOUBLE.
 01 WS-DIR                 PIC X(1100).
 01 WS-STATUS              BINARY-LONG.
 01 WS-REASON              PIC X(128).
 PROCEDURE DIVISION.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "rm -rf build/wt-packs && mkdir -p build/wt-packs" TO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
*>   A standard world as an earlier run left it: level.dat with WorldType standard and a ContentJar.
     CALL "PB-RESET" USING PB-BUFFER
     MOVE SPACES TO WN
     MOVE 0 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "WorldType" TO WN MOVE 9 TO WL
     MOVE 8 TO WS-LENGTH
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL "standard" WS-LENGTH
     MOVE "ContentJar" TO WN MOVE 10 TO WL
     MOVE 12 TO WS-LENGTH
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL "0123456789ab" WS-LENGTH
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE SPACES TO WS-FILE
     MOVE "build/wt-packs/level.dat" TO WS-FILE
     MOVE 24 TO WS-FILE-LENGTH
     CALL "PERSIST-WRITE-FILE" USING WS-FILE WS-FILE-LENGTH PB-BUFFER
     MOVE "T" TO TL-MODE

     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "build/no-such-generated-dir" TO CS-GENERATED-DIR
     CALL "CORE-WORLD-OPEN" USING WS-FOLDER CORE-SETTINGS WS-CREATED
     MOVE SPACES TO WS-DIR
     MOVE CS-GENERATED-DIR(1:1024) TO WS-DIR
     CALL "CORE-PACKS-STATUS" USING WS-DIR WS-STATUS WS-REASON
     MOVE WS-CREATED TO WS-EDIT
     MOVE CT-PACKS-STATUS TO WS-EDIT2
     MOVE SPACES TO WS-OBSERVED
     STRING FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-EDIT2) " " FUNCTION TRIM(WS-REASON) DELIMITED BY SIZE
         INTO WS-OBSERVED
     MOVE "acceptance US2 packs deleted: the standard world is refused -1 with the absent reason" TO TL-CASE
     MOVE "-1 1 Minecraft content is not set up. Run the extraction tool with your Minecraft 26.3 client jar to play standard worlds."
         TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-OBSERVED) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "contract/fixtures/content/stale" TO CS-GENERATED-DIR
     CALL "CORE-WORLD-OPEN" USING WS-FOLDER CORE-SETTINGS WS-CREATED
     MOVE SPACES TO WS-DIR
     MOVE CS-GENERATED-DIR(1:1024) TO WS-DIR
     CALL "CORE-PACKS-STATUS" USING WS-DIR WS-STATUS WS-REASON
     MOVE WS-CREATED TO WS-EDIT
     MOVE SPACES TO WS-OBSERVED
     STRING FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-REASON) DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE "acceptance US2 packs of another version: refused -1 with the stale reason" TO TL-CASE
     MOVE "-1 The Minecraft content was made for another version. Run the extraction tool again." TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-OBSERVED) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "contract/fixtures/content/valid" TO CS-GENERATED-DIR
     CALL "CORE-WORLD-OPEN" USING WS-FOLDER CORE-SETTINGS WS-CREATED
     MOVE CT-PACKS-STATUS TO WS-EDIT2
     MOVE SPACES TO WS-OBSERVED
     STRING "packs " FUNCTION TRIM(WS-EDIT2) DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE "acceptance US2 packs rebuilt: the check is ok whatever ContentJar says (informational, never compared)"
         TO TL-CASE
     MOVE "packs 0" TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-OBSERVED) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-F2US2-PACKS-CHANGED.

 COPY CORETEST.
