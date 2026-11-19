*> Convergence acceptance test of the operator report "I still can't throw Eyes of Ender" (try15 to try19; lane bugeye T62900; docs/protocol/25 section 6.3, 21 section 8.12,
*> 09 section 3.3 Use Item): in a new standard world made from the create-world screen through the client's single-player host, from the generated vanilla packs
*> (CC_GENERATED_DIR; a pass without them). The player is given three ender eyes (the give command), looks up at the sky and presses the right mouse button with no block aimed
*> at: the client sends Use Item, the core adds one eye_of_ender entity and uses up one eye, and the client's replica holds that entity (so that it is drawn). Before the fix the
*> client sent nothing for a thrown item (only for food and buckets), so the core never saw the click.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-BUGEYE-THROW.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONVH.
 COPY CLCONST.
 COPY CCSHIM.
 COPY CONTENT.
 01 WS-DIR                 PIC X(64) VALUE "build/conv-bugeye-throw".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 23.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-FOLDER              PIC X(80) VALUE "EyeThrow".
 01 WS-FOLDER-LENGTH       BINARY-LONG VALUE 8.
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
 01 WS-BUTTON              BINARY-LONG.
 01 WS-DOWN                BINARY-LONG.
 01 WS-EYE-ID              BINARY-LONG.
 01 WS-EYE-ROWS            BINARY-LONG.
 01 WS-STACK               BINARY-LONG.
 01 WS-CROW                BINARY-LONG.
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
         MOVE "acceptance bugeye: no generated packs here, skipped" TO TL-CASE
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

*>   the player is given three ender eyes and has them in the held slot
     MOVE "/give Alice ender_eye 3" TO WS-LINE
     MOVE 23 TO WS-LINE-LENGTH
     CALL "CV-SAY" USING CONVH WS-ALICE WS-LINE WS-LINE-LENGTH
     MOVE 10 TO WS-ROUND
     CALL "CV-STEPS" USING CONVH WS-ROUND
*>   and plays in survival, where a thrown eye is used up
     MOVE "/gamemode survival" TO WS-LINE
     MOVE 18 TO WS-LINE-LENGTH
     CALL "CV-SAY" USING CONVH WS-ALICE WS-LINE WS-LINE-LENGTH
     MOVE 10 TO WS-ROUND
     CALL "CV-STEPS" USING CONVH WS-ROUND
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE "N" TO TL-MODE
     MOVE "acceptance bugeye: the client holds three ender eyes in the held slot" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE PL-SLOT-COUNT(PL-HELD + 1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "BEY-CORE-EYES" USING WS-NAME WS-EYE-ID WS-EYE-ROWS WS-STACK
     MOVE "acceptance bugeye: no eye_of_ender entity flies yet" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-EYE-ROWS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   looks at the sky (up 40 degrees) and presses the right button once
     MOVE -40 TO PL-PITCH
     MOVE CC-BUTTON-RIGHT TO WS-BUTTON
     MOVE CC-EV-BUTTON-DOWN TO WS-DOWN
     CALL "CV-BUTTON-SET" USING CONVH WS-ALICE WS-BUTTON WS-DOWN
     MOVE CC-EV-BUTTON-UP TO WS-DOWN
     CALL "CV-BUTTON-SET" USING CONVH WS-ALICE WS-BUTTON WS-DOWN
     MOVE 6 TO WS-ROUND
     CALL "CV-STEPS" USING CONVH WS-ROUND
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     CALL "BEY-CORE-EYES" USING WS-NAME WS-EYE-ID WS-EYE-ROWS WS-STACK
     MOVE "acceptance bugeye: the right button with an ender eye in hand makes one eye_of_ender entity in the world" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-EYE-ROWS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance bugeye: and the survival stack of the player loses one eye" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-STACK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-FIND" USING CLIENT-STATE WS-EYE-ID WS-CROW
     MOVE "acceptance bugeye: the client's replica holds the eye entity (the Add Entity reached it)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-CROW > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-BUGEYE-THROW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BEY-CORE-EYES.
*> USING name (PIC X(16)), entity id out (the first eye_of_ender), rows out (eye_of_ender entities in use), stack out (the ender_eye count of the held slot of that player).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-KEY                 PIC X(112).
 01 WS-TYPE                BINARY-LONG.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(16).
 01 L-ID                   BINARY-LONG.
 01 L-ROWS                 BINARY-LONG.
 01 L-STACK                BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-ID L-ROWS L-STACK.
     MOVE "minecraft:eye_of_ender" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE 0 TO L-ID L-ROWS L-STACK
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > EN-COUNT
         IF EN-USED(WS-R) = 1 AND EN-TYPE(WS-R) = WS-TYPE
             ADD 1 TO L-ROWS
             IF L-ID = 0
                 MOVE EN-ID(WS-R) TO L-ID
             END-IF
         END-IF
     END-PERFORM
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > 64
         IF PL-USED(WS-R) = 1 AND PL-NAME(WS-R) = L-NAME
             MOVE PL-SLOT-COUNT(WS-R, PL-HELD(WS-R) + 1) TO L-STACK
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BEY-CORE-EYES.
