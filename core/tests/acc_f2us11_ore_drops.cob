*> Acceptance test, US11-3 (spec US11 scenario 3, 11 section 9, 26; tasks T0435): ore blocks broken in survival drop their items through
*> the loot tables. The table of cobolcraft:greystone (core/tests/fixtures/loot-blocks) is the shape of an ore's: two alternatives,
*> the first (a "silk touch" stand-in: a tool with minecraft:efficiency 4 or more, the only enchantment of the cobolcraft set) gives
*> the block's own kind (loam here), the second gives a dump shard whose count is multiplied by the ore_drops formula of the tool's
*> efficiency level (Fortune's stand-in) and decays under an explosion. Alice (survival, pry_bar in slot 8) breaks greystone at
*> (20, 100, 20) with the real Player Action start and stop; the other cases finish the break with BREAK-FINISH. World seed 12345:
*> the table's Xoroshiro128++ sequence (26 section 4) gives, for an efficiency-3 tool, the counts 4 then 3 (independent Python
*> implementation of 10 2.3 and 10 2.4). A block that requires a tool (CB-TOOL-REQ set for the case) gives nothing to a tool of
*> another class or to an empty hand (26 section 11.1 step 3); a block without a table keeps the stand-in yield.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US11-ORE-DROPS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY CITEMS.
 COPY CBLOCKS.
 COPY RULES.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/loot-blocks".
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-X                   BINARY-LONG VALUE 20.
 01 WS-Y                   BINARY-LONG VALUE 100.
 01 WS-Z                   BINARY-LONG VALUE 20.
 01 WS-GREYSTONE           BINARY-LONG VALUE 2.
 01 WS-LOAM-STATE          BINARY-LONG VALUE 3.
 01 WS-KEY                 PIC X(112).
 01 WS-FACE                BINARY-LONG VALUE 1.
 01 WS-SEQ                 BINARY-LONG VALUE 0.
 01 WS-ACTION              BINARY-LONG.
 01 WS-SLOT                BINARY-LONG VALUE 8.
 01 WS-TICKS               BINARY-LONG.
 01 WS-PRY-BAR             BINARY-LONG.
 01 WS-TROWEL              BINARY-LONG.
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-HANDLE              BINARY-LONG.
 01 WS-ID                  BINARY-LONG VALUE 0.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-BLOCK-ROW           BINARY-LONG.
 01 WS-BLOCK-TEXT          PIC X(12).
 01 WS-F                   BINARY-LONG.
 01 WS-TEXT                PIC X(300).
 01 WS-EDIT                PIC -(9)9.
 01 WS-EDIT2               PIC -(9)9.
 01 WS-R1                  PIC -(6)9.99.
 01 WS-R2                  PIC -(6)9.99.
 01 WS-R3                  PIC -(6)9.99.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-DEFAULT-MODE
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE 12345 TO CW-SEED
     CALL "LOOT-LOAD" USING WS-DIR WS-STATUS
     MOVE "acceptance US11-3 given the loot tables of the blocks when they load then the fixture tree is accepted" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM CHECK-NUM
     MOVE "Alice" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW
     MOVE "cobolcraft:pry_bar" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-PRY-BAR WS-ITEM-ROW WS-STATUS
     MOVE "cobolcraft:trowel" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-TROWEL WS-ITEM-ROW WS-STATUS
     CALL "TEST-HELD" USING WS-ALICE WS-SLOT
     MOVE 98 TO WS-Y
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-GREYSTONE
     MOVE 100 TO WS-Y
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-GREYSTONE

     MOVE "acceptance US11-3 given an ore with a loot table when it is broken in survival with a pickaxe then the "
         & "table gives its item: one dump shard at (x + 0.5, y + 0.25, z + 0.5) and the block is gone" TO TL-CASE
     MOVE 0 TO WS-ACTION
     PERFORM ACT
     MOVE 7 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE 3 TO WS-ACTION
     PERFORM ACT
     CALL "TEST-BLOCK-AT" USING WS-X WS-Y WS-Z WS-STATE
     MOVE WS-STATE TO WS-EDIT
     MOVE WS-EDIT TO WS-BLOCK-TEXT
     PERFORM DESCRIBE-DROPS
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-TEXT) " block " FUNCTION TRIM(WS-BLOCK-TEXT) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "15x1@20.50,100.25,20.50 block 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE 3 TO WS-LEVEL
     PERFORM HOLD-ENCHANTED
     PERFORM BREAK-AGAIN
     MOVE "acceptance US11-3 given a pickaxe with efficiency 3 (the Fortune stand-in) when the ore is broken then the "
         & "ore_drops formula multiplies the count by the draw of the table's sequence: 4 shards the first time" TO TL-CASE
     MOVE "15x4@20.50,100.25,20.50" TO TL-EXPECTED
     PERFORM CHECK-DROPS
     PERFORM BREAK-AGAIN
     MOVE "acceptance US11-3 given the same tool when the ore is broken again then the sequence continues: 3 shards"
         TO TL-CASE
     MOVE "15x3@20.50,100.25,20.50" TO TL-EXPECTED
     PERFORM CHECK-DROPS

     MOVE 5 TO WS-LEVEL
     PERFORM HOLD-ENCHANTED
     PERFORM BREAK-AGAIN
     MOVE "acceptance US11-3 given a pickaxe with efficiency 5 (the Silk Touch stand-in) when the ore is broken then the "
         & "block's own kind drops instead (the first alternative)" TO TL-CASE
     MOVE "3x1@20.50,100.25,20.50" TO TL-EXPECTED
     PERFORM CHECK-DROPS

     COMPUTE WS-BLOCK-ROW = CB-S-BLOCK(WS-GREYSTONE + 1) + 1
     MOVE 1 TO CB-TOOL-REQ(WS-BLOCK-ROW)
     MOVE 0 TO CB-NEED-TIER(WS-BLOCK-ROW)
     MOVE WS-TROWEL TO PL-SLOT-ITEM(WS-ROW, 9)
     MOVE 1 TO PL-SLOT-COUNT(WS-ROW, 9)
     MOVE 0 TO PL-SLOT-VAR(WS-ROW, 9)
     PERFORM BREAK-AGAIN
     MOVE "acceptance US11-3 given an ore that requires a tool when it is broken with a tool of another class (a shovel) "
         & "then it drops nothing" TO TL-CASE
     MOVE "-" TO TL-EXPECTED
     PERFORM CHECK-DROPS
     MOVE 0 TO PL-SLOT-COUNT(WS-ROW, 9)
     PERFORM BREAK-AGAIN
     MOVE "acceptance US11-3 given an ore that requires a tool when it is broken by hand then it drops nothing" TO TL-CASE
     MOVE "-" TO TL-EXPECTED
     PERFORM CHECK-DROPS
     MOVE WS-PRY-BAR TO PL-SLOT-ITEM(WS-ROW, 9)
     MOVE 1 TO PL-SLOT-COUNT(WS-ROW, 9)
     PERFORM BREAK-AGAIN
     MOVE "acceptance US11-3 given an ore that requires a tool when it is broken with a pickaxe then it drops its item "
         & "again (the sequence goes on: efficiency 0 draws nothing)" TO TL-CASE
     MOVE "15x1@20.50,100.25,20.50" TO TL-EXPECTED
     PERFORM CHECK-DROPS
     MOVE 0 TO CB-TOOL-REQ(WS-BLOCK-ROW)

     MOVE WS-LOAM-STATE TO WS-STATE
     MOVE WS-LOAM-STATE TO WS-EDIT
     MOVE 100 TO WS-Y
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-LOAM-STATE
     CALL "BREAK-FINISH" USING WS-ROW WS-DIM WS-X WS-Y WS-Z
     MOVE "acceptance US11-3 given a block with no loot table (loam) when it is broken then the stand-in yield "
         & "(the block's item) is kept" TO TL-CASE
     MOVE RULE-YIELD-ITEM(WS-LOAM-STATE + 1) TO WS-EDIT2
     MOVE SPACES TO TL-EXPECTED
     STRING FUNCTION TRIM(WS-EDIT2) "x1@20.50,100.25,20.50" DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM CHECK-DROPS
     STOP RUN.

 ACT.
     CALL "TEST-ACTION" USING WS-ALICE WS-ACTION WS-X WS-Y WS-Z WS-FACE WS-SEQ
     ADD 1 TO WS-SEQ.

*> The held pickaxe (slot 8 of the hotbar) with efficiency WS-LEVEL.
 HOLD-ENCHANTED.
     MOVE 0 TO WS-HANDLE
     CALL "SP-ADD-ENCHANT" USING WS-HANDLE WS-ID WS-LEVEL
     MOVE WS-PRY-BAR TO PL-SLOT-ITEM(WS-ROW, 9)
     MOVE 1 TO PL-SLOT-COUNT(WS-ROW, 9)
     MOVE WS-HANDLE TO PL-SLOT-VAR(WS-ROW, 9).

*> A new greystone block, then the end of the survival break.
 BREAK-AGAIN.
     MOVE 100 TO WS-Y
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-GREYSTONE
     CALL "BREAK-FINISH" USING WS-ROW WS-DIM WS-X WS-Y WS-Z.

 DESCRIBE-DROPS.
     MOVE SPACES TO WS-TEXT
     MOVE 0 TO WS-F
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
         IF EN-USED(WS-E) = 1 AND EN-TYPE(WS-E) = CR-LOOSE-ITEM
             MOVE EN-ITEM(WS-E) TO WS-EDIT
             MOVE EN-ITEM-COUNT(WS-E) TO WS-EDIT2
             MOVE EN-X(WS-E) TO WS-R1
             MOVE EN-Y(WS-E) TO WS-R2
             MOVE EN-Z(WS-E) TO WS-R3
             IF WS-F > 0
                 STRING FUNCTION TRIM(WS-TEXT) " " DELIMITED BY SIZE INTO WS-TEXT
             END-IF
             STRING FUNCTION TRIM(WS-TEXT) FUNCTION TRIM(WS-EDIT) "x" FUNCTION TRIM(WS-EDIT2) "@"
                 FUNCTION TRIM(WS-R1) "," FUNCTION TRIM(WS-R2) "," FUNCTION TRIM(WS-R3)
                 DELIMITED BY SIZE INTO WS-TEXT
             ADD 1 TO WS-F
             CALL "ENTITY-REMOVE" USING WS-E
         END-IF
     END-PERFORM
     IF WS-F = 0
         MOVE "-" TO WS-TEXT
     END-IF.

 CHECK-DROPS.
     PERFORM DESCRIBE-DROPS
     MOVE SPACES TO TL-OBSERVED
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     PERFORM CHECK.

 CHECK.
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-NUM.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-F2US11-ORE-DROPS.
 COPY CORETEST.
