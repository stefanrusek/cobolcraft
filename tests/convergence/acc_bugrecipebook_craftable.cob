*> Convergence acceptance test (operator report try18: "recipe book often lacks things that it should have"; docs/protocol/13 section 3.9
*> Craftability and 05b Recipe Book Add requirements, 27 sections 4.4 and 5.9): a standard world (the generated packs of CC_GENERATED_DIR,
*> default /tmp/cc-test/generated; a pass without them) is opened through the client's single-player host with a survival player who has the
*> starting kit (a crafting table, 8 oak planks, 8 sticks, 16 oak logs) and is given 64 each of oak_log, cobblestone, iron_ingot, stick, coal,
*> string, wheat and sand by the standard give command. The core sends the recipes those items unlock (the advancement criteria, item tags
*> included) and the client marks as craftable the entries whose requirements (an item, a list of items or an item TAG, 05b HolderSet) the
*> inventory supplies, each requirement taking its own unit. The expected count was computed independently from the data pack (python over every
*> recipe_unlocked advancement, the item tags with their nested tags and an exact matching of requirements to units, with the starting kit in the stock):
*> 88 shaped and shapeless crafting recipes are unlocked and 64 of them craftable. Before the fix the client kept only the single-item form of a
*> requirement, so every recipe with a tag or list ingredient (planks, logs, stone tool materials, coals) was never marked.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-BUGRECIPEBOOK-CRAFTABLE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONVH.
 COPY CLCONST.
 COPY CCSHIM.
 COPY CONTENT.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/conv-bugrecipebook".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 24.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-FOLDER              PIC X(80) VALUE "StdRecipeBook".
 01 WS-FOLDER-LENGTH       BINARY-LONG VALUE 13.
 01 WS-SURVIVAL            BINARY-LONG VALUE 0.
 01 WS-ALICE               BINARY-LONG.
 01 WS-JOINED              BINARY-LONG.
 01 WS-DIR-ENV             PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-LINE                PIC X(64).
 01 WS-LINE-LENGTH         BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-GRID                BINARY-LONG VALUE 3.
 01 WS-CAN                 BINARY-LONG.
 01 WS-GIVE-TABLE.
    05 FILLER              PIC X(24) VALUE "oak_log".
    05 FILLER              PIC X(24) VALUE "cobblestone".
    05 FILLER              PIC X(24) VALUE "iron_ingot".
    05 FILLER              PIC X(24) VALUE "stick".
    05 FILLER              PIC X(24) VALUE "coal".
    05 FILLER              PIC X(24) VALUE "string".
    05 FILLER              PIC X(24) VALUE "wheat".
    05 FILLER              PIC X(24) VALUE "sand".
 01 WS-GIVES REDEFINES WS-GIVE-TABLE.
    05 WS-GIVE             PIC X(24) OCCURS 8 TIMES.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE SPACES TO WS-DIR-ENV
     ACCEPT WS-DIR-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-DIR-ENV = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-DIR-ENV
     END-IF
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-DIR-ENV TRAILING) "/vanilla-data/pack.mcmeta" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE NOT = 0
         MOVE "acceptance bugrecipebook craftable: no generated packs here, skipped" TO TL-CASE
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
     MOVE CT-TYPE-STANDARD TO SP-CREATE-TYPE
     CALL "CV-HOST-OPEN" USING CONVH WS-ALICE WS-FOLDER WS-FOLDER-LENGTH WS-SURVIVAL
     MOVE 0 TO WS-JOINED
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 90 OR WS-JOINED = 1
         CALL "CV-UNTIL-PLAY" USING CONVH WS-ALICE WS-JOINED
         IF WS-JOINED = 0
             CALL "C$SLEEP" USING 1
         END-IF
     END-PERFORM
     MOVE 10 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         MOVE SPACES TO WS-LINE
         STRING "/give Alice minecraft:" FUNCTION TRIM(WS-GIVE(WS-I)) " 64" DELIMITED BY SIZE INTO WS-LINE
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-LINE TRAILING)) TO WS-LINE-LENGTH
         CALL "CV-SAY" USING CONVH WS-ALICE WS-LINE WS-LINE-LENGTH
         MOVE 8 TO WS-N
         CALL "CV-STEPS" USING CONVH WS-N
     END-PERFORM
     MOVE 10 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE 1 TO RK-DIRTY
     CALL "RECIPE-BOOK-REFRESH" USING CLIENT-STATE WS-GRID
     MOVE 0 TO WS-CAN
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RK-COUNT
         IF RK-CAN(WS-I) = 1 AND RK-TYPE(WS-I) <= 1 AND RK-CATEGORY(WS-I) <= 3
             ADD 1 TO WS-CAN
         END-IF
     END-PERFORM
     MOVE "acceptance bugrecipebook given a survival player holding oak_log, cobblestone, iron_ingot, stick, coal, string, wheat and sand "
         & "(64 each) when the book is refreshed for the 3 x 3 grid then the 64 crafting recipes the inventory supplies are craftable" TO TL-CASE
     MOVE 64 TO TL-EXPECTED-N
     MOVE WS-CAN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-BUGRECIPEBOOK-CRAFTABLE.
