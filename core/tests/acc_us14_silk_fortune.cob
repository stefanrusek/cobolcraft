*> Acceptance test (US14; docs/protocol/17 section 3.16 block loot and tools, 6.3 Silk Touch and Fortune, 26 section 11.1 and the ore_drops formula): Silk Touch and Fortune with a real tool
*> through the loot tables (LOOT-ROLL). A standard world opened from the generated vanilla data pack (CC_GENERATED_DIR, default /tmp/cc-test/generated; a pass that says so without it). Alice
*> (survival) holds a diamond or iron pickaxe whose enchantments component carries silk_touch or fortune (SP-ADD-ENCHANT with the ids of the world's enchantment registry, as the anvil and the
*> enchanting table write them) and breaks the block with the real Player Action start and finish. Diamond ore drops a diamond, itself under Silk Touch and 1 to 4 diamonds under Fortune III (the
*> formula count x (max(nextInt(L + 2) - 1, 0) + 1), more than 1 at least once in twelve breaks); coal ore the same with coal; stone gives cobblestone, stone itself under Silk Touch, and Fortune
*> changes nothing there. Without the enchantment nothing changes either.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US14-SILK-FORTUNE.
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
 01 WS-X                   BINARY-LONG VALUE 20.
 01 WS-Y                   BINARY-LONG VALUE 100.
 01 WS-Z                   BINARY-LONG VALUE 20.
 01 WS-FACE                BINARY-LONG VALUE 1.
 01 WS-SEQ                 BINARY-LONG VALUE 0.
 01 WS-ACTION              BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-BLOCK-KEY           PIC X(112).
 01 WS-TOOL-KEY            PIC X(112).
 01 WS-ENCH-KEY            PIC X(112).
 01 WS-ENCH-ID             BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-BID                 BINARY-LONG.
 01 WS-IID                 BINARY-LONG.
 01 WS-BROW                PIC X(819).
 01 WS-IROW                PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-HANDLE              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-DROPPED             BINARY-LONG.
 01 WS-DROPS               PIC X(60).
 01 WS-COUNT               BINARY-LONG.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-MIN                 BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-TEXT                PIC X(200).
 01 WS-NEAR-X              FLOAT-LONG.
 01 WS-NEAR-Y              FLOAT-LONG.
 01 WS-NEAR-Z              FLOAT-LONG.
 01 WS-WORLD-NAME          PIC X(8).
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
         MOVE "acceptance silk touch and fortune: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 0 TO CS-DEFAULT-MODE
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS
     MOVE "12345" TO CS-SEED-TEXT
     MOVE "SilkFortune" TO CS-NEW-WORLD-NAME
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-ROW
     MOVE PL-DIM(WS-ROW) TO WS-DIM

     MOVE "diamond_ore" TO WS-BLOCK-KEY
     MOVE "diamond_pickaxe" TO WS-TOOL-KEY
     MOVE SPACES TO WS-ENCH-KEY
     MOVE 0 TO WS-LEVEL
     PERFORM MINE
     MOVE "acceptance US14 3.16 diamond ore with a plain diamond pickaxe drops one diamond" TO TL-CASE
     MOVE "diamond x1" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     PERFORM CHECK-T

     MOVE "minecraft:silk_touch" TO WS-ENCH-KEY
     MOVE 1 TO WS-LEVEL
     PERFORM MINE
     MOVE "acceptance US14 6.3 diamond ore with a Silk Touch pickaxe drops the ore block itself" TO TL-CASE
     MOVE "diamond_ore x1" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     PERFORM CHECK-T

     MOVE "minecraft:fortune" TO WS-ENCH-KEY
     MOVE 3 TO WS-LEVEL
     MOVE 99 TO WS-MIN
     MOVE 0 TO WS-MAX
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 12
         PERFORM MINE
         MOVE 0 TO WS-COUNT
         IF WS-TEXT(1:9) = "diamond x"
             COMPUTE WS-COUNT = FUNCTION NUMVAL(WS-TEXT(10:5))
         END-IF
         MOVE FUNCTION MIN(WS-MIN, WS-COUNT) TO WS-MIN
         MOVE FUNCTION MAX(WS-MAX, WS-COUNT) TO WS-MAX
     END-PERFORM
     MOVE "acceptance US14 6.3 Fortune III on diamond ore: diamonds, 1 to 4 each break and more than 1 at least once in twelve" TO TL-CASE
     MOVE "ok" TO TL-EXPECTED
     MOVE "bad" TO TL-OBSERVED
     IF WS-MIN >= 1 AND WS-MAX <= 4 AND WS-MAX > 1
         MOVE "ok" TO TL-OBSERVED
     END-IF
     PERFORM CHECK-T

     MOVE "coal_ore" TO WS-BLOCK-KEY
     MOVE 0 TO WS-MIN
     MOVE 0 TO WS-MAX
     MOVE 99 TO WS-MIN
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 12
         PERFORM MINE
         MOVE 0 TO WS-COUNT
         IF WS-TEXT(1:6) = "coal x"
             COMPUTE WS-COUNT = FUNCTION NUMVAL(WS-TEXT(7:5))
         END-IF
         MOVE FUNCTION MIN(WS-MIN, WS-COUNT) TO WS-MIN
         MOVE FUNCTION MAX(WS-MAX, WS-COUNT) TO WS-MAX
     END-PERFORM
     MOVE "acceptance US14 6.3 Fortune III on coal ore: coal, 1 to 4 each break and more than 1 at least once in twelve" TO TL-CASE
     MOVE "ok" TO TL-EXPECTED
     MOVE "bad" TO TL-OBSERVED
     IF WS-MIN >= 1 AND WS-MAX <= 4 AND WS-MAX > 1
         MOVE "ok" TO TL-OBSERVED
     END-IF
     PERFORM CHECK-T

     MOVE "stone" TO WS-BLOCK-KEY
     MOVE "iron_pickaxe" TO WS-TOOL-KEY
     PERFORM MINE
     MOVE "acceptance US14 6.3 Fortune changes nothing for stone: cobblestone" TO TL-CASE
     MOVE "cobblestone x1" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     PERFORM CHECK-T

     MOVE "minecraft:silk_touch" TO WS-ENCH-KEY
     MOVE 1 TO WS-LEVEL
     PERFORM MINE
     MOVE "acceptance US14 6.3 stone with a Silk Touch iron pickaxe drops stone, not cobblestone" TO TL-CASE
     MOVE "stone x1" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     PERFORM CHECK-T

     MOVE "coal_ore" TO WS-BLOCK-KEY
     PERFORM MINE
     MOVE "acceptance US14 6.3 coal ore with a Silk Touch iron pickaxe drops the ore block" TO TL-CASE
     MOVE "coal_ore x1" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     PERFORM CHECK-T
     STOP RUN.

 CHECK-T.
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> Breaks WS-BLOCK-KEY at (20, 100, 20) with WS-TOOL-KEY in slot 0, carrying WS-ENCH-KEY at WS-LEVEL (blank: no enchantment), through the real Player Action start and finish;
*> WS-TEXT is "<item> x<count>" of the items dropped within 3 blocks of the cell (the first kind).
 MINE.
     MOVE WS-BLOCK-KEY TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BID WS-BROW WS-STATUS
     MOVE CB-DEFAULT-STATE(WS-BID + 1) TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE WS-TOOL-KEY TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-IID WS-IROW WS-STATUS
     MOVE WS-IID TO PL-SLOT-ITEM(WS-ROW, 1)
     MOVE 1 TO PL-SLOT-COUNT(WS-ROW, 1)
     MOVE 0 TO PL-SLOT-VAR(WS-ROW, 1)
     MOVE 0 TO PL-HELD(WS-ROW)
     IF WS-ENCH-KEY NOT = SPACES
         CALL "TOOL-ENCHANT-ID" USING WS-ENCH-KEY WS-ENCH-ID
         MOVE 0 TO WS-HANDLE
         CALL "SP-ADD-ENCHANT" USING WS-HANDLE WS-ENCH-ID WS-LEVEL
         MOVE WS-HANDLE TO PL-SLOT-VAR(WS-ROW, 1)
     END-IF
     MOVE 0 TO WS-ACTION
     PERFORM ACT
     COMPUTE WS-TICKS = 1.0 / PL-BREAK-RATE(WS-ROW) + 2
     IF WS-TICKS > 3000
         MOVE 3000 TO WS-TICKS
     END-IF
     CALL "TEST-TICKS-ANSWERED" USING WS-TICKS
     MOVE 3 TO WS-ACTION
     PERFORM ACT
     MOVE SPACES TO WS-TEXT
     MOVE 0 TO WS-TOTAL
     MOVE SPACES TO WS-DROPS
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > EN-COUNT
         COMPUTE WS-NEAR-X = EN-X(WS-K) - WS-X - 0.5
         COMPUTE WS-NEAR-Y = EN-Y(WS-K) - WS-Y
         COMPUTE WS-NEAR-Z = EN-Z(WS-K) - WS-Z - 0.5
         IF EN-USED(WS-K) = 1 AND EN-PLAYER(WS-K) = 0 AND EN-ITEM-COUNT(WS-K) > 0
                 AND FUNCTION ABS(WS-NEAR-X) <= 3 AND FUNCTION ABS(WS-NEAR-Y) <= 3 AND FUNCTION ABS(WS-NEAR-Z) <= 3
             MOVE EN-ITEM(WS-K) TO WS-DROPPED
             IF WS-DROPS = SPACES
                 MOVE IT-KEY(WS-DROPPED + 1) TO WS-DROPS
             END-IF
             IF IT-KEY(WS-DROPPED + 1) = WS-DROPS
                 ADD EN-ITEM-COUNT(WS-K) TO WS-TOTAL
             END-IF
             MOVE 0 TO EN-ITEM-COUNT(WS-K)
             MOVE 0 TO EN-USED(WS-K)
         END-IF
     END-PERFORM
     IF WS-DROPS = SPACES
         MOVE "none" TO WS-TEXT
     ELSE
         MOVE WS-TOTAL TO WS-EDIT
         STRING FUNCTION TRIM(WS-DROPS) " x" FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT
     END-IF.

 ACT.
     ADD 1 TO WS-SEQ
     CALL "TEST-ACTION" USING WS-CONN WS-ACTION WS-X WS-Y WS-Z WS-FACE WS-SEQ.
 END PROGRAM ACC-US14-SILK-FORTUNE.

 COPY CORETEST.
