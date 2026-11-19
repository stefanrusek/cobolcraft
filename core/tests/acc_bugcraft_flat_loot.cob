*> Acceptance test, bug lane bugcraft (guard; the crafting half of the superflat content bug is acc_bugcraft_flat_craft): WORLD-RECIPES-OPEN named
*> the types standard and debug only, so a NEW superflat world (the standard content set with the flat generator) had no recipes. WORLD-LOOT-OPEN
*> names the same two types, so this checks the other half of the set: the block loot of a superflat world. It passed before the fix (the loot
*> tables are read through the content registries, not through WORLD-LOOT-OPEN): stone broken with a wooden pickaxe drops cobblestone, the hand
*> nothing, and a diamond ore broken with an iron pickaxe a diamond, as in a standard world (acc_mining_standard). Needs the generated packs
*> (CC_GENERATED_DIR, default /tmp/cc-test/generated): without them the test passes as skipped.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-BUGCRAFT-FLAT-LOOT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY CITEMS.
 COPY CBLOCKS.
 01 WS-DIR                 PIC X(1024).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-BLOCK-KEY           PIC X(112).
 01 WS-TOOL-KEY            PIC X(112).
 01 WS-BID                 BINARY-LONG.
 01 WS-IID                 BINARY-LONG.
 01 WS-BROW                PIC X(819).
 01 WS-IROW                PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-DROPPED             BINARY-LONG.
 01 WS-DROPS               PIC X(112).
 01 WS-NEAR-X              FLOAT-LONG.
 01 WS-NEAR-Y              FLOAT-LONG.
 01 WS-NEAR-Z              FLOAT-LONG.
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
         MOVE "acceptance bugcraft loot no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "superflat" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 0 TO CS-DEFAULT-MODE
     MOVE 1 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-ROW
     MOVE PL-DIM(WS-ROW) TO WS-DIM
     COMPUTE WS-X = FUNCTION INTEGER(PL-X(WS-ROW)) + 3
     COMPUTE WS-Y = FUNCTION INTEGER(PL-Y(WS-ROW))
     COMPUTE WS-Z = FUNCTION INTEGER(PL-Z(WS-ROW))

     MOVE "acceptance bugcraft loot a NEW superflat world: stone broken with a wooden pickaxe drops cobblestone, the hand nothing, "
         & "diamond ore with an iron pickaxe a diamond" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE "stone" TO WS-BLOCK-KEY
     MOVE "wooden_pickaxe" TO WS-TOOL-KEY
     PERFORM BREAK
     MOVE FUNCTION TRIM(WS-DROPS) TO TL-OBSERVED
     MOVE SPACES TO WS-TOOL-KEY
     PERFORM BREAK
     STRING FUNCTION TRIM(TL-OBSERVED) ", " FUNCTION TRIM(WS-DROPS) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "diamond_ore" TO WS-BLOCK-KEY
     MOVE "iron_pickaxe" TO WS-TOOL-KEY
     PERFORM BREAK
     STRING FUNCTION TRIM(TL-OBSERVED) ", " FUNCTION TRIM(WS-DROPS) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "T" TO TL-MODE
     MOVE "cobblestone, none, diamond" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> Holds WS-TOOL-KEY (blank: the empty hand) in hotbar slot 1, breaks WS-BLOCK-KEY at the cell as the survival break does (BLOCK-DROPS) and puts the
*> key of the item dropped within 3 blocks (or "none") into WS-DROPS.
 BREAK.
     MOVE 0 TO PL-HELD(WS-ROW)
     MOVE 0 TO PL-SLOT-COUNT(WS-ROW, 1)
     IF WS-TOOL-KEY NOT = SPACES
         MOVE WS-TOOL-KEY TO WS-KEY
         CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-IID WS-IROW WS-STATUS
         MOVE WS-IID TO PL-SLOT-ITEM(WS-ROW, 1)
         MOVE 1 TO PL-SLOT-COUNT(WS-ROW, 1)
         MOVE 0 TO PL-SLOT-VAR(WS-ROW, 1)
     END-IF
     MOVE WS-BLOCK-KEY TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BID WS-BROW WS-STATUS
     MOVE CB-DEFAULT-STATE(WS-BID + 1) TO WS-STATE
     CALL "BLOCK-DROPS" USING WS-DIM WS-X WS-Y WS-Z WS-STATE WS-BID WS-ROW
     MOVE "none" TO WS-DROPS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         COMPUTE WS-NEAR-X = EN-X(WS-I) - WS-X - 0.5
         COMPUTE WS-NEAR-Y = EN-Y(WS-I) - WS-Y
         COMPUTE WS-NEAR-Z = EN-Z(WS-I) - WS-Z - 0.5
         IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0 AND EN-ITEM-COUNT(WS-I) > 0
                 AND FUNCTION ABS(WS-NEAR-X) <= 3 AND FUNCTION ABS(WS-NEAR-Y) <= 3 AND FUNCTION ABS(WS-NEAR-Z) <= 3
             MOVE EN-ITEM(WS-I) TO WS-DROPPED
             MOVE SPACES TO WS-DROPS
             MOVE IT-KEY(WS-DROPPED + 1) TO WS-DROPS
             MOVE 0 TO EN-ITEM-COUNT(WS-I)
             MOVE 0 TO EN-USED(WS-I)
         END-IF
     END-PERFORM.
 END PROGRAM ACC-BUGCRAFT-FLAT-LOOT.

 COPY CORETEST.
