*> Acceptance test, lane mining (operator report: breaking stone with a wooden pickaxe dropped nothing and was not faster than by hand;
*> 13 section 2.1 and 2.6, 17 section 1.3 and 1.4, 26 section 11.1): a standard world opened from the generated vanilla data pack
*> (CC_GENERATED_DIR, default /tmp/cc-test/generated; skipped as a pass without it), whose block and item keys have no namespace.
*> Alice (survival) holds a tool and breaks a block with the real Player Action start and finish; the break rate (progress per tick)
*> and the ground item of the break are observed. A block that needs a tool drops its loot only to a tool that is correct for drops
*> (stone: any pickaxe; iron ore: stone or better; diamond ore: iron or better; obsidian: diamond or better), and the tool speed
*> multiplies the rate (wooden pickaxe 2, stone 4, iron 6, diamond 8).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-MINING-STANDARD.
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
 01 WS-TOOL-KEY            PIC X(112).
 01 WS-BLOCK-KEY           PIC X(112).
 01 WS-BID                 BINARY-LONG.
 01 WS-IID                 BINARY-LONG.
 01 WS-BROW                PIC X(819).
 01 WS-IROW                PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-RATE                PIC -(3)9.9999.
 01 WS-COUNT-EDIT          PIC -(9)9.
 01 WS-TEXT                PIC X(300).
 01 WS-DROPS               PIC X(200).
 01 WS-DROPPED             BINARY-LONG.
 01 WS-KEYS                BINARY-LONG.
 01 WS-COMMAND             PIC X(768).
 01 WS-SLOT-NO             BINARY-LONG.
 01 WS-WORLD               PIC X(64) VALUE Z"build/core-test-world".
 01 WS-CREATED             BINARY-LONG.
 01 WS-DAMAGE              BINARY-LONG VALUE 5.
 01 WS-HANDLE              BINARY-LONG.
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
         MOVE "acceptance mining standard no generated packs here, skipped" TO TL-CASE
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
     MOVE "Mining" TO CS-NEW-WORLD-NAME
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-ROW
     MOVE PL-DIM(WS-ROW) TO WS-DIM

     MOVE "acceptance mining stone: the rate in progress per tick is 0.0067 by hand, 0.0444 wooden, 0.0889 stone, "
         & "0.1333 iron, 0.1778 diamond, and the loot only for a pickaxe" TO TL-CASE
     MOVE SPACES TO WS-TEXT
     MOVE "stone" TO WS-BLOCK-KEY
     MOVE SPACES TO WS-TOOL-KEY
     PERFORM MINE
     MOVE "wooden_pickaxe" TO WS-TOOL-KEY
     PERFORM MINE
     MOVE "stone_pickaxe" TO WS-TOOL-KEY
     PERFORM MINE
     MOVE "iron_pickaxe" TO WS-TOOL-KEY
     PERFORM MINE
     MOVE "diamond_pickaxe" TO WS-TOOL-KEY
     PERFORM MINE
     MOVE "wooden_axe" TO WS-TOOL-KEY
     PERFORM MINE
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     MOVE "0.0067 none, 0.0444 cobblestone, 0.0889 cobblestone, 0.1333 cobblestone, 0.1778 cobblestone, 0.0067 none"
         TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance mining iron_ore: nothing for hand or wooden pickaxe, raw_iron from stone up" TO TL-CASE
     MOVE SPACES TO WS-TEXT
     MOVE "iron_ore" TO WS-BLOCK-KEY
     MOVE SPACES TO WS-TOOL-KEY
     PERFORM MINE
     MOVE "wooden_pickaxe" TO WS-TOOL-KEY
     PERFORM MINE
     MOVE "stone_pickaxe" TO WS-TOOL-KEY
     PERFORM MINE
     MOVE "iron_pickaxe" TO WS-TOOL-KEY
     PERFORM MINE
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     MOVE "0.0033 none, 0.0067 none, 0.0444 raw_iron, 0.0667 raw_iron" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance mining diamond_ore: nothing for stone, diamond from iron up" TO TL-CASE
     MOVE SPACES TO WS-TEXT
     MOVE "diamond_ore" TO WS-BLOCK-KEY
     MOVE "stone_pickaxe" TO WS-TOOL-KEY
     PERFORM MINE
     MOVE "iron_pickaxe" TO WS-TOOL-KEY
     PERFORM MINE
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     MOVE "0.0133 none, 0.0667 diamond" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance mining obsidian: nothing for iron, itself for diamond" TO TL-CASE
     MOVE SPACES TO WS-TEXT
     MOVE "obsidian" TO WS-BLOCK-KEY
     MOVE "iron_pickaxe" TO WS-TOOL-KEY
     PERFORM MINE
     MOVE "diamond_pickaxe" TO WS-TOOL-KEY
     PERFORM MINE
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     MOVE "0.0012 none, 0.0053 obsidian" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance mining dirt and logs: dirt drops to a hand and faster to a shovel, an oak log faster to an axe"
         TO TL-CASE
     MOVE SPACES TO WS-TEXT
     MOVE "dirt" TO WS-BLOCK-KEY
     MOVE SPACES TO WS-TOOL-KEY
     PERFORM MINE
     MOVE "wooden_shovel" TO WS-TOOL-KEY
     PERFORM MINE
     MOVE "oak_log" TO WS-BLOCK-KEY
     MOVE SPACES TO WS-TOOL-KEY
     PERFORM MINE
     MOVE "wooden_axe" TO WS-TOOL-KEY
     PERFORM MINE
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     MOVE "0.0667 dirt, 0.1333 dirt, 0.0167 oak_log, 0.0333 oak_log" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance mining stone: a wooden pickaxe given with the give command (a stack from the command, not a slot I wrote) "
         & "drops cobblestone, the hand nothing" TO TL-CASE
     PERFORM VARYING WS-SLOT-NO FROM 1 BY 1 UNTIL WS-SLOT-NO > 36
         MOVE 0 TO PL-SLOT-COUNT(WS-ROW, WS-SLOT-NO)
     END-PERFORM
     MOVE "give Alice minecraft:wooden_pickaxe" TO WS-COMMAND
     CALL "TEST-COMMAND" USING WS-CONN WS-COMMAND
     PERFORM FIND-HELD
     MOVE SPACES TO WS-TEXT
     MOVE "stone" TO WS-BLOCK-KEY
     MOVE SPACES TO WS-TOOL-KEY
     PERFORM MINE-HELD
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     MOVE "0.0444 cobblestone" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance mining stone: the wooden pickaxe of a saved player, used (damage 5) (the world saved and opened again, Alice joining from her "
         & "player file) drops cobblestone as well" TO TL-CASE
     COMPUTE WS-SLOT-NO = PL-HELD(WS-ROW) + 1
     MOVE PL-SLOT-VAR(WS-ROW, WS-SLOT-NO) TO WS-HANDLE
     CALL "SP-SET-DAMAGE" USING WS-HANDLE WS-DAMAGE
     MOVE WS-HANDLE TO PL-SLOT-VAR(WS-ROW, WS-SLOT-NO)
     MOVE PL-SLOT-ITEM(WS-ROW, WS-SLOT-NO) TO PL-SLOT-ITEM(WS-ROW, 5)
     MOVE PL-SLOT-COUNT(WS-ROW, WS-SLOT-NO) TO PL-SLOT-COUNT(WS-ROW, 5)
     MOVE WS-HANDLE TO PL-SLOT-VAR(WS-ROW, 5)
     MOVE 0 TO PL-SLOT-COUNT(WS-ROW, WS-SLOT-NO)
     MOVE 4 TO PL-HELD(WS-ROW)
     CALL "CORE-CONN-CLOSED" USING WS-CONN
     CALL "CORE-SAVE"
     CALL "CORE-WORLD-OPEN" USING WS-WORLD CORE-SETTINGS WS-CREATED
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-ROW
     MOVE PL-DIM(WS-ROW) TO WS-DIM
     MOVE SPACES TO WS-TEXT
     PERFORM MINE-HELD
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     MOVE "0.0444 cobblestone" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> Holds the slot with the first stack there is (the hotbar first).
 FIND-HELD.
     MOVE 0 TO PL-HELD(WS-ROW)
     PERFORM VARYING WS-SLOT-NO FROM 36 BY -1 UNTIL WS-SLOT-NO < 1
         IF PL-SLOT-COUNT(WS-ROW, WS-SLOT-NO) > 0 AND WS-SLOT-NO <= 9
             COMPUTE PL-HELD(WS-ROW) = WS-SLOT-NO - 1
         END-IF
     END-PERFORM.

*> Like MINE but keeps the held slot as it is.
 MINE-HELD.
     MOVE WS-BLOCK-KEY TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BID WS-BROW WS-STATUS
     MOVE CB-DEFAULT-STATE(WS-BID + 1) TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE 0 TO WS-ACTION
     PERFORM ACT
     COMPUTE WS-RATE ROUNDED = PL-BREAK-RATE(WS-ROW)
     COMPUTE WS-TICKS = 1.0 / PL-BREAK-RATE(WS-ROW) + 2
     CALL "TEST-TICKS-ANSWERED" USING WS-TICKS
     MOVE 3 TO WS-ACTION
     PERFORM ACT
     MOVE "none" TO WS-DROPS
     PERFORM VARYING WS-KEYS FROM 1 BY 1 UNTIL WS-KEYS > EN-COUNT
         COMPUTE WS-NEAR-X = EN-X(WS-KEYS) - WS-X - 0.5
         COMPUTE WS-NEAR-Y = EN-Y(WS-KEYS) - WS-Y
         COMPUTE WS-NEAR-Z = EN-Z(WS-KEYS) - WS-Z - 0.5
         IF EN-USED(WS-KEYS) = 1 AND EN-PLAYER(WS-KEYS) = 0 AND EN-ITEM-COUNT(WS-KEYS) > 0
                 AND FUNCTION ABS(WS-NEAR-X) <= 3 AND FUNCTION ABS(WS-NEAR-Y) <= 3 AND FUNCTION ABS(WS-NEAR-Z) <= 3
             MOVE EN-ITEM(WS-KEYS) TO WS-DROPPED
             MOVE SPACES TO WS-DROPS
             MOVE IT-KEY(WS-DROPPED + 1) TO WS-DROPS
             MOVE 0 TO EN-ITEM-COUNT(WS-KEYS)
             MOVE 0 TO EN-USED(WS-KEYS)
         END-IF
     END-PERFORM
     STRING FUNCTION TRIM(WS-RATE) " " FUNCTION TRIM(WS-DROPS) DELIMITED BY SIZE INTO WS-TEXT.

*> Breaks WS-BLOCK-KEY with WS-TOOL-KEY (blank: the empty hand) held in slot 0 and appends "rate drop" to WS-TEXT. Only an item within 3 blocks of the cell counts (a mob
*> that died elsewhere in the world, such as a squid, drops its own loot).
 MINE.
     MOVE 0 TO WS-I
     MOVE WS-BLOCK-KEY TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BID WS-BROW WS-STATUS
     MOVE CB-DEFAULT-STATE(WS-BID + 1) TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE 0 TO PL-SLOT-COUNT(WS-ROW, 1)
     IF WS-TOOL-KEY NOT = SPACES
         MOVE WS-TOOL-KEY TO WS-KEY
         CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-IID WS-IROW WS-STATUS
         MOVE WS-IID TO PL-SLOT-ITEM(WS-ROW, 1)
         MOVE 1 TO PL-SLOT-COUNT(WS-ROW, 1)
         MOVE 0 TO PL-SLOT-VAR(WS-ROW, 1)
     END-IF
     MOVE 0 TO PL-HELD(WS-ROW)
     MOVE 0 TO WS-ACTION
     PERFORM ACT
     COMPUTE WS-RATE ROUNDED = PL-BREAK-RATE(WS-ROW)
     COMPUTE WS-TICKS = 1.0 / PL-BREAK-RATE(WS-ROW) + 2
     IF WS-TICKS > 3000
         MOVE 3000 TO WS-TICKS
     END-IF
     CALL "TEST-TICKS-ANSWERED" USING WS-TICKS
     MOVE 3 TO WS-ACTION
     PERFORM ACT
     MOVE "none" TO WS-DROPS
     PERFORM VARYING WS-KEYS FROM 1 BY 1 UNTIL WS-KEYS > EN-COUNT
         COMPUTE WS-NEAR-X = EN-X(WS-KEYS) - WS-X - 0.5
         COMPUTE WS-NEAR-Y = EN-Y(WS-KEYS) - WS-Y
         COMPUTE WS-NEAR-Z = EN-Z(WS-KEYS) - WS-Z - 0.5
         IF EN-USED(WS-KEYS) = 1 AND EN-PLAYER(WS-KEYS) = 0 AND EN-ITEM-COUNT(WS-KEYS) > 0
                 AND FUNCTION ABS(WS-NEAR-X) <= 3 AND FUNCTION ABS(WS-NEAR-Y) <= 3 AND FUNCTION ABS(WS-NEAR-Z) <= 3
             MOVE EN-ITEM(WS-KEYS) TO WS-DROPPED
             MOVE SPACES TO WS-DROPS
             MOVE IT-KEY(WS-DROPPED + 1) TO WS-DROPS
             MOVE 0 TO EN-ITEM-COUNT(WS-KEYS)
             MOVE 0 TO EN-USED(WS-KEYS)
         END-IF
     END-PERFORM
     IF WS-TEXT NOT = SPACES
         STRING FUNCTION TRIM(WS-TEXT) ", " FUNCTION TRIM(WS-RATE) " " FUNCTION TRIM(WS-DROPS)
             DELIMITED BY SIZE INTO WS-TEXT
     ELSE
         STRING FUNCTION TRIM(WS-RATE) " " FUNCTION TRIM(WS-DROPS) DELIMITED BY SIZE INTO WS-TEXT
     END-IF.

 ACT.
     ADD 1 TO WS-SEQ
     CALL "TEST-ACTION" USING WS-CONN WS-ACTION WS-X WS-Y WS-Z WS-FACE WS-SEQ.
 END PROGRAM ACC-MINING-STANDARD.

 COPY CORETEST.

 COPY CMDTEST.
