*> Acceptance test, bug lane bugcraft (operator report, try15: "I couldn't craft anything in the crafting bench" in a NEW superflat world;
*> crafting worked earlier in the same session in a standard world). A world's recipes are the content of its set, loaded when
*> the world opens (WORLD-CONTENT-OPEN, WORLD-RECIPES-OPEN): that named the types standard and debug only, so a superflat world (the
*> standard content set with the flat generator) was given the ten cobolcraft built-in recipes, none of the data pack recipes (the
*> block loot of such a world is fine, acc_bugcraft_flat_loot): no vanilla grid ever matched and the result slot stayed empty, while the 4 planks of a log, the crafting table and the sticks come
*> from the generated data pack.
*> Through the real packet path (Use Item On a placed crafting table opens the bench menu, Container Click picks up, places and takes,
*> docs/protocol/13 sections 3.5 and 3.6) a survival player makes planks from a log (shapeless, 3 x 3 grid), a crafting table from four
*> planks (shaped 2 x 2, ingredient tag) and sticks from two planks (shaped 1 x 2), in a standard world, a superflat world and a debug
*> world, and in a superflat world saved and opened again (the client asks for cobolcraft there, its level.dat says superflat).
*> Needs the generated packs (CC_GENERATED_DIR, default /tmp/cc-test/generated): without them the test passes as skipped.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-BUGCRAFT-FLAT-CRAFT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY CITEMS.
 COPY CBLOCKS.
 COPY CMENU.
 01 WS-DIR                 PIC X(1024).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-TYPE                PIC X(10).
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-FACE                BINARY-LONG VALUE 1.
 01 WS-SEQ                 BINARY-LONG VALUE 0.
 01 WS-KEY                 PIC X(112).
 01 WS-BID                 BINARY-LONG.
 01 WS-BROW                PIC X(819).
 01 WS-IID                 BINARY-LONG.
 01 WS-IROW                PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-GIVE-KEY            PIC X(112).
 01 WS-GIVE-COUNT          BINARY-LONG.
 01 WS-CELLS               PIC X(9).
 01 WS-CELL-AT             BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-BUTTON              BINARY-LONG.
 01 WS-CLICK               BINARY-LONG.
 01 WS-LOG                 PIC X(160).
 01 WS-STEP-TEXT           PIC X(60).
 01 WS-COUNT-EDIT          PIC -(9)9.
 01 WS-TEXT                PIC X(300).
 01 WS-WORLD               PIC X(64) VALUE Z"build/core-test-world".
 01 WS-CREATED             BINARY-LONG.
 PROCEDURE DIVISION.
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
         MOVE "N" TO TL-MODE
         MOVE "acceptance bugcraft no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF

*>   the superflat world first: the loot store of an earlier world of the process would hide a world that loads none
     MOVE "superflat" TO WS-TYPE
     PERFORM CRAFT-IN-WORLD
     MOVE "acceptance bugcraft a NEW superflat world: a log gives 4 planks, 4 planks a crafting table, 2 planks 4 sticks in the bench"
         TO TL-CASE
     PERFORM CHECK-LOG

*>   the same superflat world saved and opened again the way the client opens a saved world: the request is cobolcraft, its level.dat says superflat
     CALL "CORE-CONN-CLOSED" USING WS-CONN
     CALL "CORE-SAVE"
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "cobolcraft" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 0 TO CS-DEFAULT-MODE
     MOVE 1 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "CORE-WORLD-OPEN" USING WS-WORLD CORE-SETTINGS WS-CREATED
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     PERFORM CRAFT-STEPS
     MOVE "acceptance bugcraft a saved superflat world opened again (request cobolcraft): the same three crafts in the bench" TO TL-CASE
     PERFORM CHECK-LOG

     MOVE "standard" TO WS-TYPE
     PERFORM CRAFT-IN-WORLD
     MOVE "acceptance bugcraft a standard world: a log gives 4 planks, 4 planks a crafting table, 2 planks 4 sticks in the bench"
         TO TL-CASE
     PERFORM CHECK-LOG

     MOVE "debug" TO WS-TYPE
     PERFORM CRAFT-IN-WORLD
     MOVE "acceptance bugcraft a debug world: a log gives 4 planks, 4 planks a crafting table, 2 planks 4 sticks in the bench"
         TO TL-CASE
     PERFORM CHECK-LOG
     STOP RUN.

 CHECK-LOG.
     MOVE "T" TO TL-MODE
     MOVE FUNCTION TRIM(WS-LOG) TO TL-OBSERVED
     MOVE "oak_planks 4, crafting_table 1, stick 4" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> A new world of WS-TYPE, a survival player at its spawn, a crafting table next to it, opened with Use Item On; the three crafts.
 CRAFT-IN-WORLD.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE WS-TYPE TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 0 TO CS-DEFAULT-MODE
     MOVE 1 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     PERFORM CRAFT-STEPS.

*> The three crafts of a joined player: a bench next to it, opened with Use Item On.
 CRAFT-STEPS.
     MOVE CN-PLAYER(WS-CONN) TO WS-ROW
     MOVE PL-DIM(WS-ROW) TO WS-DIM
     COMPUTE WS-X = FUNCTION INTEGER(PL-X(WS-ROW)) + 1
     COMPUTE WS-Y = FUNCTION INTEGER(PL-Y(WS-ROW))
     COMPUTE WS-Z = FUNCTION INTEGER(PL-Z(WS-ROW))
     MOVE SPACES TO WS-KEY
     MOVE "crafting_table" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BID WS-BROW WS-STATUS
     MOVE CB-DEFAULT-STATE(WS-BID + 1) TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE SPACES TO WS-LOG
     MOVE 0 TO PL-HELD(WS-ROW)

*>   a log, one cell: planks
     PERFORM EMPTY-INVENTORY
     MOVE "oak_log" TO WS-GIVE-KEY
     MOVE 1 TO WS-GIVE-COUNT
     PERFORM GIVE
     PERFORM OPEN-BENCH
     MOVE "1........" TO WS-CELLS
     PERFORM CRAFT

*>   four planks, a 2 x 2 square in the top-left of the 3 x 3 grid: a crafting table
     PERFORM EMPTY-INVENTORY
     MOVE "oak_planks" TO WS-GIVE-KEY
     MOVE 4 TO WS-GIVE-COUNT
     PERFORM GIVE
     MOVE "11.11...." TO WS-CELLS
     PERFORM CRAFT

*>   two planks, one above the other: sticks
     PERFORM EMPTY-INVENTORY
     MOVE "oak_planks" TO WS-GIVE-KEY
     MOVE 2 TO WS-GIVE-COUNT
     PERFORM GIVE
     MOVE "1..1....." TO WS-CELLS
     PERFORM CRAFT.

*> Clears the inventory, the cursor and the bench grid (the result of the last craft is on the cursor).
 EMPTY-INVENTORY.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
         MOVE 0 TO PL-SLOT-COUNT(WS-ROW, WS-I) PL-SLOT-ITEM(WS-ROW, WS-I) PL-SLOT-VAR(WS-ROW, WS-I)
     END-PERFORM
     MOVE 0 TO PL-CARRIED-COUNT(WS-ROW) PL-CARRIED-ITEM(WS-ROW) PL-CARRIED-VAR(WS-ROW).

*> The item WS-GIVE-KEY x WS-GIVE-COUNT in hotbar slot 1 (menu slot 37 of a bench menu).
 GIVE.
     MOVE SPACES TO WS-KEY
     MOVE WS-GIVE-KEY TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-IID WS-IROW WS-STATUS
     MOVE WS-IID TO PL-SLOT-ITEM(WS-ROW, 1)
     MOVE WS-GIVE-COUNT TO PL-SLOT-COUNT(WS-ROW, 1)
     MOVE 0 TO PL-SLOT-VAR(WS-ROW, 1).

 OPEN-BENCH.
     ADD 1 TO WS-SEQ
     CALL "TEST-USE-ON" USING WS-CONN WS-X WS-Y WS-Z WS-FACE WS-SEQ.

*> Picks the stack of hotbar slot 1 up (menu slot 37), puts one of it into every grid cell marked 1 of WS-CELLS (right click),
*> takes the result (slot 0) and appends "<item key> <count>" to WS-LOG.
 CRAFT.
     MOVE 37 TO WS-SLOT
     MOVE 0 TO WS-BUTTON WS-CLICK
     CALL "BC-CLICK" USING WS-CONN MN-WINDOW(WS-ROW) WS-SLOT WS-BUTTON WS-CLICK
     PERFORM VARYING WS-CELL-AT FROM 1 BY 1 UNTIL WS-CELL-AT > 9
         IF WS-CELLS(WS-CELL-AT:1) = "1"
             MOVE WS-CELL-AT TO WS-SLOT
             MOVE 1 TO WS-BUTTON
             CALL "BC-CLICK" USING WS-CONN MN-WINDOW(WS-ROW) WS-SLOT WS-BUTTON WS-CLICK
         END-IF
     END-PERFORM
     MOVE 0 TO WS-SLOT WS-BUTTON
     CALL "BC-CLICK" USING WS-CONN MN-WINDOW(WS-ROW) WS-SLOT WS-BUTTON WS-CLICK
     MOVE SPACES TO WS-STEP-TEXT
     IF PL-CARRIED-COUNT(WS-ROW) = 0
         MOVE "nothing" TO WS-STEP-TEXT
     ELSE
         MOVE PL-CARRIED-COUNT(WS-ROW) TO WS-COUNT-EDIT
         STRING FUNCTION TRIM(IT-KEY(PL-CARRIED-ITEM(WS-ROW) + 1)) " " FUNCTION TRIM(WS-COUNT-EDIT)
             DELIMITED BY SIZE INTO WS-STEP-TEXT
     END-IF
     IF WS-LOG = SPACES
         MOVE WS-STEP-TEXT TO WS-LOG
     ELSE
         STRING FUNCTION TRIM(WS-LOG) ", " FUNCTION TRIM(WS-STEP-TEXT) DELIMITED BY SIZE INTO WS-LOG
     END-IF.
 END PROGRAM ACC-BUGCRAFT-FLAT-CRAFT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BC-CLICK.
*> USING connection id, container id, slot, button, click type (BINARY-LONG): feeds Container Click on that container with the player's
*> current state id of its menu (TEST-CLICK sends container 0 only).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 COPY CMENU.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-PACKET-ID           BINARY-LONG VALUE 18.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-WINDOW               BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-BUTTON               BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-WINDOW L-SLOT L-BUTTON L-TYPE.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-WINDOW
     CALL "PB-PUT-VARINT" USING PB-BUFFER MN-STATE-ID(CN-PLAYER(L-ID))
     CALL "PB-PUT-SHORT" USING PB-BUFFER L-SLOT
     CALL "PB-PUT-BYTE" USING PB-BUFFER L-BUTTON
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-TYPE
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-ZERO
     CALL "TEST-FEED-BUFFER" USING L-ID PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM BC-CLICK.

 COPY CORETEST.
