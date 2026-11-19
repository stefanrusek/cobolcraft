*> Real-data test (skipped as a pass without the generated packs; lane buglocate3 T43402, operator report of try15: `village` is no structure, so the operator needs the completion to find
*> the right name). Tab completion of `/locate structure <word>` through the real Command Suggestion path: the structure argument asks the server (ask_server), which lists the
*> entries of the registry minecraft:worldgen/structure and the structure tags (data/minecraft/tags/worldgen/structure, written with a leading #) that match the typed text as the
*> game's resource suggestions do (15 section 14.2, suggestResource: with a colon the whole namespace:path must match by prefix or after . _ /; without it the namespace or the path;
*> a tag also matches by the text after the #). Typing `village` offers minecraft:village_plains, _desert, _savanna, _snowy, _taiga and #minecraft:village (tags are offered for the typed
*> text with or without a #, so the operator who typed the tag's name finds the #). The standard world of the generated packs, an operator.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-SUGGEST-LOCATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 01 WS-ENV                 PIC X(1024).
 01 WS-DIR                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-ID-OPAL             BINARY-LONG.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-LINE                PIC X(768).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-TEXT                PIC X(4096).
 01 WS-DISCARD             PIC X(4096).
 01 WS-SUGGESTION-ID       BINARY-LONG VALUE 1.
 01 WS-EXPECTED            PIC X(1024).
 01 WS-HEAD                PIC X(4096).
 01 WS-WORD                PIC X(80).
 01 WS-WORD-LENGTH         BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-ENTRIES             BINARY-LONG.
 01 WS-VILLAGES            BINARY-LONG.
 01 WS-HASHES              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-REGISTRY            PIC X(112).
 01 WS-TAG-COUNT           BINARY-LONG.
 01 WS-TAG-NAMES.
    05 WS-TAG-NAME         PIC X(64) OCCURS 256 TIMES.
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
         MOVE "acceptance suggest locate: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE "12345" TO CS-SEED-TEXT
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Opal" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-ID-OPAL
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD

*>   `village`: the five village structures and the village tags, nothing that does not hold the word
     MOVE "/locate structure village" TO WS-LINE
     MOVE 25 TO WS-LENGTH
     PERFORM ASK
     MOVE "suggest locate: village starts at the word (18) and is 7 long" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "1 18 7 [" TO WS-EXPECTED
     MOVE SPACES TO WS-HEAD
     MOVE WS-TEXT(1:8) TO WS-HEAD
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-HEAD
     MOVE "N" TO TL-MODE
     MOVE "minecraft:village_plains" TO WS-WORD
     PERFORM HAS-WORD
     MOVE "#minecraft:village" TO WS-WORD
     PERFORM HAS-WORD
     MOVE "minecraft:village_desert" TO WS-WORD
     PERFORM HAS-WORD
     MOVE "minecraft:village_savanna" TO WS-WORD
     PERFORM HAS-WORD
     MOVE "minecraft:village_snowy" TO WS-WORD
     PERFORM HAS-WORD
     MOVE "minecraft:village_taiga" TO WS-WORD
     PERFORM HAS-WORD
     PERFORM ALL-HOLD-VILLAGE
     MOVE "suggest locate: every entry offered for village holds the word (no stronghold, no mineshaft)" TO TL-CASE
     MOVE WS-ENTRIES TO TL-EXPECTED-N
     MOVE WS-VILLAGES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "suggest locate: the structures are not repeated (7 or fewer entries with the tags of the villages' maps)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-ENTRIES >= 6 AND WS-ENTRIES <= 16
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   a typed # offers only tags
     MOVE "/locate structure #vil" TO WS-LINE
     MOVE 22 TO WS-LENGTH
     PERFORM ASK
     MOVE "#minecraft:village" TO WS-WORD
     PERFORM HAS-WORD
     MOVE 0 TO WS-HASHES
     MOVE 0 TO WS-COUNT
     INSPECT WS-TEXT TALLYING WS-COUNT FOR ALL ","
     COMPUTE WS-ENTRIES = WS-COUNT + 1
     MOVE 0 TO WS-HASHES
     INSPECT WS-TEXT TALLYING WS-HASHES FOR ALL "#minecraft:"
     MOVE "suggest locate: a typed #vil offers tags only (every entry has the #)" TO TL-CASE
     MOVE WS-ENTRIES TO TL-EXPECTED-N
     MOVE WS-HASHES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   a typed namespace:path is matched whole
     MOVE "/locate structure minecraft:village_p" TO WS-LINE
     MOVE 37 TO WS-LENGTH
     PERFORM ASK
     MOVE "suggest locate: minecraft:village_p offers exactly minecraft:village_plains" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "1 18 19 [minecraft:village_plains]" TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "N" TO TL-MODE

*>   a path word after _ matches, a prefix of the path matches
     MOVE "/locate structure plains" TO WS-LINE
     MOVE 24 TO WS-LENGTH
     PERFORM ASK
     MOVE "minecraft:village_plains" TO WS-WORD
     PERFORM HAS-WORD
     MOVE "/locate structure stronghold" TO WS-LINE
     MOVE 28 TO WS-LENGTH
     PERFORM ASK
     MOVE "minecraft:stronghold" TO WS-WORD
     PERFORM HAS-WORD

*>   nothing typed: every structure and every tag
     MOVE "/locate structure " TO WS-LINE
     MOVE 18 TO WS-LENGTH
     PERFORM ASK
     MOVE "minecraft:mineshaft" TO WS-WORD
     PERFORM HAS-WORD
     MOVE "#minecraft:village" TO WS-WORD
     PERFORM HAS-WORD
     MOVE "#minecraft:mineshaft" TO WS-WORD
     PERFORM HAS-WORD
     MOVE "minecraft:ancient_city" TO WS-WORD
     PERFORM HAS-WORD

*>   the tag lister: a registry with a tag folder, one without, one of another namespace
     MOVE SPACES TO WS-REGISTRY
     MOVE "minecraft:worldgen/structure" TO WS-REGISTRY
     CALL "BR-SUGGEST-TAGS" USING WS-REGISTRY WS-TAG-COUNT WS-TAG-NAMES
     MOVE "suggest locate: the structure tags are listed (more than 10, the first is minecraft:abandoned_camp)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-TAG-COUNT > 10 AND WS-TAG-NAME(1) = "minecraft:abandoned_camp"
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO WS-REGISTRY
     MOVE "minecraft:worldgen/no_such_registry" TO WS-REGISTRY
     CALL "BR-SUGGEST-TAGS" USING WS-REGISTRY WS-TAG-COUNT WS-TAG-NAMES
     MOVE "suggest locate: a registry without a tag folder has no tags" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-TAG-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO WS-REGISTRY
     MOVE "cobolcraft:worldgen/structure" TO WS-REGISTRY
     CALL "BR-SUGGEST-TAGS" USING WS-REGISTRY WS-TAG-COUNT WS-TAG-NAMES
     MOVE "suggest locate: a registry of another namespace has no tags" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-TAG-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> The line WS-LINE (WS-LENGTH bytes) is asked about at its end and the answer is in WS-TEXT.
 ASK.
     CALL "TEST-SUGGEST" USING WS-ID-OPAL WS-SUGGESTION-ID WS-LINE WS-LENGTH
     CALL "TEST-DRAIN-SUGGESTIONS" USING WS-ID-OPAL WS-TEXT.

*> WS-WORD is an entry of the answer: between a [ or a comma and a comma or a ].
 HAS-WORD.
     MOVE 0 TO WS-COUNT
     COMPUTE WS-WORD-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(WS-WORD))
     MOVE SPACES TO WS-EXPECTED
     STRING "[" FUNCTION TRIM(WS-WORD) "," DELIMITED BY SIZE INTO WS-EXPECTED
     INSPECT WS-TEXT TALLYING WS-COUNT FOR ALL FUNCTION TRIM(WS-EXPECTED)
     MOVE SPACES TO WS-EXPECTED
     STRING "," FUNCTION TRIM(WS-WORD) "," DELIMITED BY SIZE INTO WS-EXPECTED
     INSPECT WS-TEXT TALLYING WS-COUNT FOR ALL FUNCTION TRIM(WS-EXPECTED)
     MOVE SPACES TO WS-EXPECTED
     STRING "," FUNCTION TRIM(WS-WORD) "]" DELIMITED BY SIZE INTO WS-EXPECTED
     INSPECT WS-TEXT TALLYING WS-COUNT FOR ALL FUNCTION TRIM(WS-EXPECTED)
     MOVE SPACES TO WS-EXPECTED
     STRING "[" FUNCTION TRIM(WS-WORD) "]" DELIMITED BY SIZE INTO WS-EXPECTED
     INSPECT WS-TEXT TALLYING WS-COUNT FOR ALL FUNCTION TRIM(WS-EXPECTED)
     MOVE SPACES TO TL-CASE
     STRING "suggest locate: " FUNCTION TRIM(WS-LINE) " offers " FUNCTION TRIM(WS-WORD) DELIMITED BY SIZE INTO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> WS-ENTRIES: the entries of the answer; WS-VILLAGES: how many times the answer holds the text "village" (once in each entry that matches).
 ALL-HOLD-VILLAGE.
     MOVE 0 TO WS-COUNT
     INSPECT WS-TEXT TALLYING WS-COUNT FOR ALL ","
     COMPUTE WS-ENTRIES = WS-COUNT + 1
     MOVE 0 TO WS-VILLAGES
     INSPECT WS-TEXT TALLYING WS-VILLAGES FOR ALL "village".
 END PROGRAM TEST-CMD-SUGGEST-LOCATE.

 COPY NOSPAWN.
 COPY CORETEST.
 COPY CMDTEST.
