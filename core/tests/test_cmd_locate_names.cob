*> Real-data test (skipped as a pass without the generated packs; lane buglocate3 T43401, operator report of try15: "/locate structure #minecraft:village works, but /locate structure
*> village does not"). docs/protocol/16 section 7.7: the structure argument is a resource_or_tag_key (15 section 6.7): a plain identifier is a registry KEY that the parser does not check;
*> the command resolves it and an id that is not a structure of the registry is `commands.locate.structure.invalid` [id] ("There is no structure with type ...", error); the tag
*> #minecraft:village and the five structures village_plains ... village_taiga resolve, an identifier without a namespace is in minecraft:. There is no structure `village` or
*> `minecraft:village` (vanilla rejects them too: the villages are village_plains, village_desert, village_savanna, village_snowy, village_taiga and the tag #minecraft:village), so the
*> answer to `locate structure village` is the invalid error with minecraft:village, as the console, execute and a player's own line show it. A standard world of the generated
*> packs, an operator through the real command path.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-LOCATE-NAMES.
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
 01 WS-TEXT                PIC X(4096).
 01 WS-DISCARD             PIC X(4096).
 01 WS-EXPECTED            PIC X(1024).
 01 WS-HEAD                PIC X(4096).
 01 WS-COUNT               BINARY-LONG.
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
         MOVE "acceptance locate names: no generated packs here, skipped" TO TL-CASE
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

*>   the names that are no structure of the registry: the vanilla error, with the id in minecraft:
     MOVE "acceptance locate names: village (no namespace) is no structure: commands.locate.structure.invalid [minecraft:village]" TO TL-CASE
     MOVE "locate structure village" TO WS-LINE
     MOVE "commands.locate.structure.invalid(minecraft:village)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance locate names: minecraft:village is no structure either" TO TL-CASE
     MOVE "locate structure minecraft:village" TO WS-LINE
     PERFORM RUN-TEXT
     MOVE "acceptance locate names: an id of another namespace is printed as typed" TO TL-CASE
     MOVE "locate structure cobolcraft:nope" TO WS-LINE
     MOVE "commands.locate.structure.invalid(cobolcraft:nope)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance locate names: nested in execute the same error" TO TL-CASE
     MOVE "execute run locate structure village" TO WS-LINE
     MOVE "commands.locate.structure.invalid(minecraft:village)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance locate names: the console prints the English text of the error" TO TL-CASE
     MOVE "locate structure village" TO WS-LINE
     MOVE "There is no structure with type ""minecraft:village""" TO WS-EXPECTED
     CALL "TEST-RUN-CONSOLE" USING WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance locate names: no search is queued for a refused name (the reply is at once)" TO TL-CASE
     MOVE "locate structure village" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE 0 TO WS-COUNT
     INSPECT WS-TEXT TALLYING WS-COUNT FOR ALL "not_found"
     MOVE WS-COUNT TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE

*>   the names that resolve: the tag and the five structures, with and without the namespace
     MOVE "acceptance locate names: the tag #minecraft:village is found" TO TL-CASE
     MOVE "locate structure #minecraft:village" TO WS-LINE
     MOVE "commands.locate.structure.success(#minecraft:village," TO WS-EXPECTED
     PERFORM RUN-START
     MOVE "acceptance locate names: village_plains (no namespace) is the structure minecraft:village_plains" TO TL-CASE
     MOVE "locate structure village_plains" TO WS-LINE
     MOVE "commands.locate.structure.success(minecraft:village_plains," TO WS-EXPECTED
     PERFORM RUN-START
     MOVE "acceptance locate names: a village structure is no invalid name: village_desert" TO TL-CASE
     MOVE "locate structure minecraft:village_desert" TO WS-LINE
     PERFORM RUN-NOT-INVALID
     MOVE "acceptance locate names: village_savanna" TO TL-CASE
     MOVE "locate structure village_savanna" TO WS-LINE
     PERFORM RUN-NOT-INVALID
     MOVE "acceptance locate names: village_snowy" TO TL-CASE
     MOVE "locate structure village_snowy" TO WS-LINE
     PERFORM RUN-NOT-INVALID
     MOVE "acceptance locate names: village_taiga" TO TL-CASE
     MOVE "locate structure village_taiga" TO WS-LINE
     PERFORM RUN-NOT-INVALID
     MOVE "acceptance locate names: another structure, mineshaft (no namespace)" TO TL-CASE
     MOVE "locate structure mineshaft" TO WS-LINE
     PERFORM RUN-NOT-INVALID
     STOP RUN.

*> The line is run by Opal and the replies are compared with WS-EXPECTED.
 RUN-TEXT.
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT.

*> The reply must begin with WS-EXPECTED.
 RUN-START.
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE SPACES TO WS-HEAD
     MOVE WS-TEXT(1:FUNCTION LENGTH(FUNCTION TRIM(WS-EXPECTED))) TO WS-HEAD
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-HEAD.

*> The reply is the success or the not_found text of the search: never the invalid error (the observed text is the key up to its first parenthesis).
 RUN-NOT-INVALID.
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE 0 TO WS-COUNT
     INSPECT WS-TEXT TALLYING WS-COUNT FOR ALL "commands.locate.structure.invalid"
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-COUNT
     INSPECT WS-TEXT TALLYING WS-COUNT FOR ALL "commands.locate.structure."
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE.
 END PROGRAM TEST-CMD-LOCATE-NAMES.

 COPY NOSPAWN.
 COPY CORETEST.
 COPY CMDTEST.
