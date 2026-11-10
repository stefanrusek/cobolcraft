*> Acceptance test US2-3 (spec 002 FR-003, FR-004, FR-005, FR-037; SC-011; docs/design/world-types.md §2.1, §8.2):
*> the world list shows each world's type (level.dat WorldType; a world without one is a cobolcraft world); with
*> the packs not ok, opening a standard world is refused with the reason, the world is not opened; a cobolcraft
*> world opens.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US2-WORLD-LIST.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CONTENT.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/client-test-f2-world-list".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 31.
 01 WS-SCREEN              BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-ARG                 BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-HITS                BINARY-LONG.
 01 WS-JOINED              BINARY-LONG.
 01 WS-FOLDER              PIC X(80).
 01 WS-NAME                PIC X(64).
 01 WS-MODE                BINARY-LONG.
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-FOLDER-LENGTH       BINARY-LONG.
 01 WS-TYPE                PIC X(16).
 01 WS-TYPE-LENGTH         BINARY-LONG.
 01 WS-E1                  PIC 9.
 01 WS-E2                  PIC 99.
 01 WS-E3                  PIC 9.
 01 WS-T1                  BINARY-LONG.
 01 WS-T2                  BINARY-LONG.
 01 WS-T3                  BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-SP-START" USING CLIENT-STATE WS-DIR WS-DIR-LENGTH
     MOVE CT-PACKS-STALE TO CL-PACKS-STATUS
     CALL "SYSTEM" USING "mkdir -p build/client-test-f2-world-list/saves"
*>   b_cobol is a real world made by the core (its folder holds every file a world needs); a_std and
*>   c_none are only a level.dat: the first is refused before the core is asked, the second is only listed.
     MOVE "b_cobol" TO WS-FOLDER
     MOVE 7 TO WS-FOLDER-LENGTH
     MOVE "b_cobol" TO WS-NAME
     MOVE 7 TO WS-NAME-LENGTH
     MOVE 0 TO WS-MODE
     CALL "SP-OPEN" USING CLIENT-STATE WS-FOLDER WS-FOLDER-LENGTH WS-NAME WS-NAME-LENGTH WS-MODE
     CALL "TEST-SP-JOIN" USING CLIENT-STATE WS-JOINED
     CALL "SP-QUIT" USING CLIENT-STATE
     MOVE "a_std" TO WS-FOLDER
     MOVE 5 TO WS-FOLDER-LENGTH
     MOVE "standard" TO WS-TYPE
     MOVE 8 TO WS-TYPE-LENGTH
     CALL "TEST-MAKE-WORLD" USING WS-DIR WS-FOLDER WS-FOLDER-LENGTH WS-TYPE WS-TYPE-LENGTH
     MOVE "c_none" TO WS-FOLDER
     MOVE 6 TO WS-FOLDER-LENGTH
     MOVE 0 TO WS-TYPE-LENGTH
     CALL "TEST-MAKE-WORLD" USING WS-DIR WS-FOLDER WS-FOLDER-LENGTH WS-TYPE WS-TYPE-LENGTH

     MOVE SCR-WORLD-LIST TO WS-SCREEN
     CALL "SCREEN-OPEN" USING CLIENT-STATE WS-SCREEN
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-TEXT
     MOVE "acceptance US2-3 given three worlds when the world list opens then each row shows its type: "
         & "standard, cobolcraft, and cobolcraft for a world with no WorldType" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     MOVE ZERO TO WS-HITS
     INSPECT WS-TEXT TALLYING WS-HITS FOR ALL "Type: Standard"
     MOVE WS-HITS TO WS-E1
     MOVE ZERO TO WS-HITS
     INSPECT WS-TEXT TALLYING WS-HITS FOR ALL "Type: CobolCraft"
     MOVE WS-HITS TO WS-E3
     MOVE WL-COUNT TO WS-E2
     STRING WS-E1 " " WS-E3 " " WS-E2 DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "1 2 03" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The standard world is the first row (byte order of the folders): Play is refused with the reason.
     MOVE ACT-SELECT TO WS-ACTION
     MOVE 1 TO WS-ARG
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     MOVE ACT-PLAY-WORLD TO WS-ACTION
     MOVE 0 TO WS-ARG
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-TEXT
     MOVE ZERO TO WS-HITS
     INSPECT WS-TEXT TALLYING WS-HITS FOR ALL "Standard worlds need the Minecraft content"
     MOVE WS-HITS TO WS-E1
     MOVE SM-SCREEN TO WS-E2
     MOVE SP-ACTIVE TO WS-E3
     MOVE "acceptance US2-3 given the packs are stale when Play is clicked on the standard world then "
         & "it is refused with the reason and not opened" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING WS-E1 " screen " WS-E2 " active " WS-E3 DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "1 screen 13 active 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The cobolcraft world opens whatever the packs are.
     MOVE ACT-SELECT TO WS-ACTION
     MOVE 2 TO WS-ARG
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     MOVE ACT-PLAY-WORLD TO WS-ACTION
     MOVE 0 TO WS-ARG
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     CALL "TEST-SP-JOIN" USING CLIENT-STATE WS-JOINED
     MOVE WS-JOINED TO WS-E1
     MOVE SP-ACTIVE TO WS-E3
     MOVE "acceptance US2-3 given the packs are stale when Play is clicked on the cobolcraft world then "
         & "it opens" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING "joined " WS-E1 " active " WS-E3 DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "joined 1 active 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "SP-QUIT" USING CLIENT-STATE

*>   The type of a world's level.dat text: standard, the hidden debug, anything else cobolcraft.
     MOVE SPACES TO WS-TYPE
     MOVE "standard" TO WS-TYPE
     CALL "WORLD-TYPE-ID" USING WS-TYPE WS-T1
     MOVE "debug" TO WS-TYPE
     CALL "WORLD-TYPE-ID" USING WS-TYPE WS-T2
     MOVE "Standard" TO WS-TYPE
     CALL "WORLD-TYPE-ID" USING WS-TYPE WS-T3
     MOVE WS-T1 TO WS-E1
     MOVE WS-T2 TO WS-E2
     MOVE WS-T3 TO WS-E3
     MOVE "acceptance US2-3 the type text of a level.dat maps to standard (0), debug (2); another text, "
         & "even Standard, is a cobolcraft world (1)" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     STRING WS-E1 " " WS-E2 " " WS-E3 DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "0 02 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-F2US2-WORLD-LIST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MAKE-WORLD.
*> USING game dir (PIC X(64), 31 characters), folder (X(32)), folder length, world type (X(16), the
*> WorldType string), its length (0 = no WorldType tag): a level.dat in saves/<folder> (07 §9.2 subset:
*> DataVersion, LevelName = the folder name, GameMode 0, then WorldType).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 1024.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-COMMAND             PIC X(256).
 01 WS-PATH                PIC X(256).
 01 WS-PATH-LENGTH         BINARY-LONG.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-INT                 BINARY-LONG.
 01 WS-TEXT                PIC X(64).
 LINKAGE SECTION.
 01 L-DIR                  PIC X(64).
 01 L-FOLDER               PIC X(80).
 01 L-FOLDER-LENGTH        BINARY-LONG.
 01 L-TYPE                 PIC X(16).
 01 L-TYPE-LENGTH          BINARY-LONG.
 PROCEDURE DIVISION USING L-DIR L-FOLDER L-FOLDER-LENGTH L-TYPE L-TYPE-LENGTH.
     MOVE LOW-VALUES TO WS-COMMAND
     STRING "mkdir -p " L-DIR(1:31) "/saves/" L-FOLDER(1:L-FOLDER-LENGTH) DELIMITED BY SIZE
         INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     MOVE SPACES TO WS-PATH
     STRING L-DIR(1:31) "/saves/" L-FOLDER(1:L-FOLDER-LENGTH) "/level.dat" DELIMITED BY SIZE
         INTO WS-PATH
     COMPUTE WS-PATH-LENGTH = 31 + 7 + L-FOLDER-LENGTH + 10
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE SPACES TO WN
     MOVE 0 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "DataVersion" TO WN
     MOVE 11 TO WL
     MOVE 5023 TO WS-INT
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-INT
     MOVE "LevelName" TO WN
     MOVE 9 TO WL
     MOVE SPACES TO WS-TEXT
     MOVE L-FOLDER(1:L-FOLDER-LENGTH) TO WS-TEXT
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-TEXT L-FOLDER-LENGTH
     MOVE "GameMode" TO WN
     MOVE 8 TO WL
     MOVE 0 TO WS-INT
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-INT
     IF L-TYPE-LENGTH > 0
         MOVE "WorldType" TO WN
         MOVE 9 TO WL
         MOVE SPACES TO WS-TEXT
         MOVE L-TYPE(1:L-TYPE-LENGTH) TO WS-TEXT
         CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-TEXT L-TYPE-LENGTH
     END-IF
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "NBT-FILE-WRITE" USING WS-PATH WS-PATH-LENGTH PB-BUFFER WS-OUTCOME
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM TEST-MAKE-WORLD.
 COPY CLTEST.
