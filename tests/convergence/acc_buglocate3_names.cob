*> Convergence acceptance test of the operator report "/locate structure #minecraft:village works, but /locate structure village does not" (try15; lane buglocate3 T43403;
*> docs/protocol/16 section 7.7, 15 sections 6.7 and 14): in a new standard world made from the create-world screen through the client's single-player host, from the generated vanilla
*> packs (CC_GENERATED_DIR; a pass without them). `village` names no structure (the villages are village_plains ... and the tag #minecraft:village), so the chat of the
*> player shows the localized error of the game, There is no structure with type "minecraft:village", not the translation key and not the parser's "Can't find element"; and Tab
*> completion of `/locate structure village` shows the player the names that do exist: minecraft:village_plains, ... and #minecraft:village.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-BUGLOCATE3-NAMES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONVH.
 COPY CLCONST.
 COPY CONTENT.
 01 WS-DIR                 PIC X(64) VALUE "build/conv-buglocate3-names".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 27.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-FOLDER              PIC X(80) VALUE "LocateNames".
 01 WS-FOLDER-LENGTH       BINARY-LONG VALUE 11.
 01 WS-MODE                BINARY-LONG VALUE 1.
 01 WS-ALICE               BINARY-LONG.
 01 WS-JOINED              BINARY-LONG.
 01 WS-DIR-ENV             PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-SCREEN              BINARY-LONG VALUE SCR-CREATE-WORLD.
 01 WS-LINE                PIC X(64).
 01 WS-LINE-LENGTH         BINARY-LONG.
 01 WS-ROUND               BINARY-LONG.
 01 WS-CHAT                PIC X(4096).
 01 WS-SUGGESTED           PIC X(1024).
 01 WS-HAS                 BINARY-LONG.
 01 WS-FRAMES              BINARY-LONG.
 01 WS-PAUSE               PIC 9V99 VALUE 0.25.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     MOVE SPACES TO WS-DIR-ENV
     ACCEPT WS-DIR-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-DIR-ENV = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-DIR-ENV
     END-IF
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-DIR-ENV TRAILING) "/vanilla-data/pack.mcmeta" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE NOT = 0
         MOVE "N" TO TL-MODE
         MOVE "acceptance buglocate3: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "CV-INIT" USING CONVH WS-DIR WS-DIR-LENGTH
     CALL "CV-CLIENT-ADD" USING CONVH WS-NAME WS-NAME-LENGTH WS-ALICE
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE SPACES TO CL-GENERATED-DIR
     MOVE WS-DIR-ENV TO CL-GENERATED-DIR
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-DIR-ENV TRAILING)) TO CL-GENERATED-DIR-LENGTH
     CALL "PACKS-STATUS-CHECK" USING CLIENT-STATE
     CALL "PACKS-RELOAD" USING CLIENT-STATE
     CALL "SCREEN-OPEN" USING CLIENT-STATE WS-SCREEN
     MOVE CT-TYPE-STANDARD TO SP-CREATE-TYPE
     CALL "CV-HOST-OPEN" USING CONVH WS-ALICE WS-FOLDER WS-FOLDER-LENGTH WS-MODE
     CALL "CV-UNTIL-PLAY" USING CONVH WS-ALICE WS-JOINED
*>   the loading screen is left when the chunks round the player have come from the generation workers (real time)
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     PERFORM VARYING WS-ROUND FROM 1 BY 1 UNTIL WS-ROUND > 800 OR SM-SCREEN = SCR-WORLD
         MOVE 10 TO WS-FRAMES
         CALL "CV-STEPS" USING CONVH WS-FRAMES
         CALL "C$SLEEP" USING WS-PAUSE
         SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     END-PERFORM

*>   the player types the command of the report
     MOVE "/locate structure village" TO WS-LINE
     MOVE 25 TO WS-LINE-LENGTH
     CALL "CV-SAY" USING CONVH WS-ALICE WS-LINE WS-LINE-LENGTH
     MOVE 10 TO WS-ROUND
     CALL "CV-STEPS" USING CONVH WS-ROUND
     CALL "CV-CHAT-LOG" USING CONVH WS-ALICE WS-CHAT

     MOVE "N" TO TL-MODE
     MOVE 0 TO WS-HAS
     INSPECT WS-CHAT TALLYING WS-HAS FOR ALL "There is no structure with type ""minecraft:village"""
     MOVE "acceptance buglocate3: /locate structure village shows the localized error: There is no structure with type minecraft:village" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-HAS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-HAS
     INSPECT WS-CHAT TALLYING WS-HAS FOR ALL "commands.locate" ALL "Can't find element" ALL "argument.resource"
     MOVE "acceptance buglocate3: and neither a translation key nor the parser's error is shown" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-HAS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Tab completion of the same line lists the names that exist
     MOVE "/locate structure village" TO WS-LINE
     CALL "B3N-SUGGEST" USING CONVH WS-ALICE WS-LINE WS-LINE-LENGTH WS-SUGGESTED
     MOVE 0 TO WS-HAS
     INSPECT WS-SUGGESTED TALLYING WS-HAS FOR ALL "minecraft:village_plains"
     MOVE "acceptance buglocate3: completion of /locate structure village offers minecraft:village_plains" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-HAS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-HAS
     INSPECT WS-SUGGESTED TALLYING WS-HAS FOR ALL "#minecraft:village"
     MOVE "acceptance buglocate3: and the tag #minecraft:village" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-HAS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-BUGLOCATE3-NAMES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. B3N-SUGGEST.
*> USING CONVH, client index, line text (PIC X(64), with its leading /), length, out (PIC X(1024)): the chat opened
*> (T), the line typed, three frames; the local suggestions then the server's answers, space-separated; the chat
*> closed (Escape).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CCSHIM.
 01 WS-T                   BINARY-LONG VALUE CC-KEY-T.
 01 WS-ESCAPE              BINARY-LONG VALUE CC-KEY-ESCAPE.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-I                   BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 COPY CONVH.
 COPY CLSTATE.
 01 L-INDEX                BINARY-LONG.
 01 L-TEXT                 PIC X(64).
 01 L-LENGTH               BINARY-LONG.
 01 L-OUT                  PIC X(1024).
 PROCEDURE DIVISION USING CONVH L-INDEX L-TEXT L-LENGTH L-OUT.
     CALL "CV-KEY" USING CONVH L-INDEX WS-T
     CALL "CV-TYPE" USING CONVH L-INDEX L-TEXT L-LENGTH
     CALL "CV-STEPS" USING CONVH WS-THREE
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(L-INDEX)
     MOVE SPACES TO L-OUT
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CS-COUNT
         MOVE CS-LENGTH(WS-I) TO WS-LENGTH
         IF WS-I > 1
             STRING " " DELIMITED BY SIZE INTO L-OUT WITH POINTER WS-PTR
         END-IF
         STRING CS-TEXT(WS-I)(1:WS-LENGTH) DELIMITED BY SIZE INTO L-OUT WITH POINTER WS-PTR
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CS-ANSWERS
         MOVE CS-A-LENGTH(WS-I) TO WS-LENGTH
         IF WS-PTR > 1
             STRING " " DELIMITED BY SIZE INTO L-OUT WITH POINTER WS-PTR
         END-IF
         STRING CS-A-TEXT(WS-I)(1:WS-LENGTH) DELIMITED BY SIZE INTO L-OUT WITH POINTER WS-PTR
     END-PERFORM
     CALL "CV-KEY" USING CONVH L-INDEX WS-ESCAPE
     GOBACK.
 END PROGRAM B3N-SUGGEST.
