*> Real-data test (user bug: the recipe book of a standard world was empty): when the full generated packs are present (the directory
*> of the environment variable CC_GENERATED_DIR, default /tmp/cc-test/generated; the case is skipped, as a pass, when it holds no
*> vanilla-data), WORLD-RECIPES-OPEN loads every data pack recipe (the store holds more than a thousand, minecraft:stick among them,
*> and the unlock advancements are parsed), and a joining player is sent a Recipe Book Add that lists some of them.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-WORLD-RECIPES-REAL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY CTRECIPE.
 01 WS-DIR                 PIC X(1024).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-TYPE                PIC X(10) VALUE "standard".
 01 WS-STATUS              BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-PROW                BINARY-LONG.
 01 WS-ITEM               BINARY-LONG.
 01 WS-ITEM-ROW           PIC X(270).
 01 WS-TEXT                PIC X(4096).
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-ENV = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-DIR
     ELSE
         MOVE WS-ENV TO WS-DIR
     END-IF
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-DIR TRAILING) "/vanilla-data/pack.mcmeta" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE NOT = 0
         MOVE "test world recipes real no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "test world recipes real the standard world opens with the generated recipes" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF CW-OPEN = "Y" AND RC-COUNT > 1000
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:stick" TO WS-KEY
     CALL "RECIPE-FIND" USING WS-KEY WS-ROW
     MOVE "test world recipes real finds minecraft:stick" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-ROW > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   a vanilla player starts with the recipes whose advancement has the tick trigger, no more ...
     CALL "TEST-JOIN-UNDRAINED" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     CALL "TEST-DRAIN-CRAFT" USING WS-ALICE WS-TEXT
     MOVE "test world recipes real a new survival player joins with a small recipe book (the tick-unlocked recipes only)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-TEXT(1:16) = "settings | book " AND WS-TEXT(17:1) NOT = "0" AND WS-TEXT(18:1) = SPACE
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   ... and a log in the inventory unlocks the planks recipes (Recipe Book Add, replace clear)
     MOVE "minecraft:oak_log" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
     MOVE CN-PLAYER(WS-ALICE) TO WS-PROW
     MOVE WS-ITEM TO PL-SLOT-ITEM(WS-PROW, 1)
     MOVE 1 TO PL-SLOT-COUNT(WS-PROW, 1)
     MOVE "N" TO TL-MODE
     CALL "CRAFT-REFRESH-ALL"
     CALL "TEST-DRAIN-CRAFT" USING WS-ALICE WS-TEXT
     MOVE "test world recipes real a log in the inventory unlocks recipes (replace clear)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-TEXT(1:5) = "book " AND WS-TEXT(1:7) NOT = "book 0 "
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-WORLD-RECIPES-REAL.
 COPY CORETEST.
