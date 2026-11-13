*> Acceptance test US2 (core-host-delta.md section 2; world-types.md sections 2.1, 3.3, 3.5 E4, WT-3, WT-24; FR-003,
*> FR-004, FR-005, FR-037): a server that cannot use or create its world stops with exit code 10 and the reason on the
*> console, and changes nothing: a standard setting with packs not ok (E4: no world folder is made), an existing
*> standard world with packs not ok, packs that check ok but do not load, a folder with saved chunks and no level.dat
*> (WT-24), a level.dat whose WorldType is another string. An existing cobolcraft world with the setting standard
*> opens as cobolcraft and the console says that the setting is ignored (WT-1). Each refusal runs in a forked child
*> (SVT-FORK) whose output goes to stdout.txt. Runs in build/server-test-refusal.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US2-REFUSAL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY PROTO.
 01 WS-SCRATCH             PIC X(256) VALUE "build/server-test-refusal".
 01 WS-CONF                PIC X(4096).
 01 WS-CAPTURE             PIC X(256) VALUE "stdout.txt".
 01 WS-CAPTURED            PIC X(4096).
 01 WS-STDERR              PIC X(4096).
 01 WS-PID                 BINARY-LONG.
 01 WS-EXIT                BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-LENGTH         BINARY-LONG.
 01 WS-INFO                PIC X(16).
 01 WS-COMMAND             PIC X(256).
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-TYPE                PIC X(16).
 01 WS-TYPE-LENGTH         BINARY-LONG.
 01 WS-CREATED             BINARY-LONG.
 01 WS-WORLD               PIC X(16) VALUE Z"./world".
 01 WS-STALE               PIC X(160) VALUE "The Minecraft content was made for another version. Run the extraction tool again.".
 PROCEDURE DIVISION.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "T" TO TL-MODE

*>   E4: standard configured, stale packs, no world folder: the reason and the tool command line, exit 10, no folder.
     PERFORM FRESH
     MOVE "port=25582|world-type=standard|generated-dir=../../contract/fixtures/content/stale" TO WS-CONF
     PERFORM RUN-CHILD
     MOVE "acceptance US2 given world-type standard and stale packs when the server starts then it prints the reason and "
         & "the tool command line and exits 10" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     STRING "exit 10 " FUNCTION TRIM(WS-STALE) " cobolcraft-extract --jar <file>" DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM CHECK
     CALL "CBL_CHECK_FILE_EXIST" USING WS-WORLD WS-INFO
     MOVE "acceptance US2 given that refusal then no world folder was made" TO TL-CASE
     MOVE "no folder" TO TL-EXPECTED
     MOVE "no folder" TO TL-OBSERVED
     IF RETURN-CODE = 0
         MOVE "folder made" TO TL-OBSERVED
     END-IF
     MOVE 0 TO RETURN-CODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Packs that check ok whose data does not load (the fixture tree holds no data): the damaged text.
     PERFORM FRESH
     MOVE "port=25582|world-type=standard|generated-dir=../../contract/fixtures/content/valid" TO WS-CONF
     PERFORM RUN-CHILD
     MOVE "acceptance US2 given packs that check ok but do not load when a standard world is asked for then it exits 10 "
         & "with the damaged text" TO TL-CASE
     MOVE "exit 10 The Minecraft content is damaged. Run the extraction tool with --force. cobolcraft-extract --jar <file>"
         TO TL-EXPECTED
     PERFORM CHECK

*>   Saved chunks and no level.dat (WT-24).
     PERFORM FRESH
     CALL "SYSTEM" USING Z"mkdir -p world/dimensions/cobolcraft/main/region && touch world/dimensions/cobolcraft/main/region/r.0.0.mca"
     MOVE "port=25582|world-type=cobolcraft" TO WS-CONF
     PERFORM RUN-CHILD
     MOVE "acceptance US2 given a folder with saved chunks and no level.dat when the server starts then it exits 10 and says so"
         TO TL-CASE
     MOVE "exit 10 This folder holds world data but no level.dat." TO TL-EXPECTED
     PERFORM CHECK

*>   A level.dat whose WorldType is another string (rule 4).
     PERFORM FRESH
     CALL "SYSTEM" USING Z"mkdir -p world"
     MOVE "Standard" TO WS-TYPE
     MOVE 8 TO WS-TYPE-LENGTH
     PERFORM WRITE-LEVEL
     MOVE "port=25582|world-type=cobolcraft" TO WS-CONF
     PERFORM RUN-CHILD
     MOVE "acceptance US2 given a WorldType of another string when the server starts then it exits 10 and says the world "
         & "cannot be opened" TO TL-CASE
     MOVE "exit 10 This world has no world type and cannot be opened." TO TL-EXPECTED
     PERFORM CHECK

*>   An existing standard world with packs not ok is refused, not altered.
     PERFORM FRESH
     CALL "SYSTEM" USING Z"mkdir -p world"
     MOVE "standard" TO WS-TYPE
     MOVE 8 TO WS-TYPE-LENGTH
     PERFORM WRITE-LEVEL
     MOVE "port=25582|generated-dir=../../contract/fixtures/content/damaged" TO WS-CONF
     PERFORM RUN-CHILD
     MOVE "acceptance US2 given an existing standard world and damaged packs when the server starts then it exits 10 with "
         & "the damaged text" TO TL-CASE
     MOVE "exit 10 The Minecraft content is damaged. Run the extraction tool with --force. cobolcraft-extract --jar <file>"
         TO TL-EXPECTED
     PERFORM CHECK

*>   An existing cobolcraft world with the setting standard: opens as cobolcraft, the setting is ignored (WT-1).
     PERFORM FRESH
     MOVE "port=25582|world-type=cobolcraft|generated-dir=../../contract/fixtures/content/stale" TO WS-CONF
     CALL "SVT-WRITE-CONF" USING WS-CONF
     CALL "SV-START"
     CALL "CORE-SAVE"
     CALL "SV-SHUTDOWN"
     MOVE "port=25582|world-type=standard|generated-dir=../../contract/fixtures/content/stale" TO WS-CONF
     CALL "SVT-WRITE-CONF" USING WS-CONF
     CALL "SVT-CAPTURE-START" USING WS-CAPTURE
     CALL "SV-START"
     CALL "SVT-CAPTURE-STOP" USING WS-CAPTURE WS-CAPTURED
     CALL "SVT-UNSTAMP" USING WS-CAPTURED
     MOVE "acceptance US2 given a cobolcraft world and world-type standard when the server starts then the world opens as "
         & "cobolcraft and the setting is reported ignored" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     STRING "Standard worlds are unavailable: " FUNCTION TRIM(WS-STALE) " | world-type=standard is ignored: this world is "
         "cobolcraft | Ready: accepting players on 0.0.0.0:25582" DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE WS-CAPTURED TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "SV-SHUTDOWN"
     CALL "SVT-HOME"
     STOP RUN.

 FRESH.
     CALL "SVT-HOME"
     CALL "SVT-SCRATCH" USING WS-SCRATCH.

 RUN-CHILD.
     CALL "SVT-WRITE-CONF" USING WS-CONF
     CALL "SVT-FORK" USING WS-PID
     IF WS-PID = 0
         CALL "SVT-CAPTURE-START" USING WS-CAPTURE
         CALL "SV-START"
         STOP RUN
     END-IF
     CALL "SVT-WAIT" USING WS-PID WS-EXIT WS-STDERR
     CALL "SVT-READ-LINES" USING WS-CAPTURE WS-CAPTURED
     CALL "SVT-UNSTAMP" USING WS-CAPTURED
     MOVE SPACES TO TL-EXPECTED TL-OBSERVED
     MOVE WS-EXIT TO WS-EDIT
     STRING "exit " FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-CAPTURED) DELIMITED BY SIZE INTO TL-OBSERVED.

 CHECK.
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 WRITE-LEVEL.
     CALL "PB-RESET" USING PB-BUFFER
     MOVE SPACES TO WN
     MOVE 0 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "WorldType" TO WN
     MOVE 9 TO WL
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-TYPE WS-TYPE-LENGTH
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE SPACES TO WS-FILE
     MOVE "world/level.dat" TO WS-FILE
     MOVE 15 TO WS-FILE-LENGTH
     CALL "PERSIST-WRITE-FILE" USING WS-FILE WS-FILE-LENGTH PB-BUFFER.
 END PROGRAM ACC-F2US2-REFUSAL.
 COPY SVTEST.
