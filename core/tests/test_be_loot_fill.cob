*> Implementation test (docs/protocol/26-loot-and-predicates.md section 5.4 and 11.6; 31-block-entities-1 section 9.3): BE-LOOT-FILL, the lazy fill of a
*> container that carries a loot table key (BE-LOOT, BE-SEED), run at the first open (MENU-CONT-OPEN, both halves of a double chest) and when
*> the block is broken (BE-DROP-CONTENTS). The tables are core/tests/fixtures/loot-chest (hand-built: c_split, c_mixed, c_fixed). The expected slots
*> come from an independent Python model of the Java LCG (10 2.6) and of the steps of 5.4 (shuffled empty slots, split of the stacks with count above 1,
*> shuffle, last slot first); each case also checks the next nextInt(1000) of the context random (how many draws the fill consumed).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BE-LOOT-FILL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CMENU.
 COPY BESTATE.
 COPY CBLOCKS.
 COPY COREAPI.
 COPY LOOTSTATE.
 COPY CITEMS.
 COPY CONTENT.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/loot-chest".
 01 WS-STATUS              BINARY-LONG.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-ID                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-BE                  BINARY-LONG.
 01 WS-BE2                 BINARY-LONG.
 01 WS-OPENED              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-TABLE               PIC X(64).
 01 WS-LEN                 BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE.
 01 WS-PROBE               BINARY-LONG.
 01 WS-BOUND               BINARY-LONG VALUE 1000.
 01 WS-TEXT                PIC X(300).
 01 WS-PREV                PIC X(300).
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-BEFORE              BINARY-LONG.
 01 WS-AFTER               BINARY-LONG.
 01 WS-FIRST-STATE         BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-DEFAULT-MODE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-ADD-CONTAINERS"
     CALL "LOOT-LOAD" USING WS-DIR WS-STATUS
     MOVE "test be loot fill the fixture tables load" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
     MOVE 0 TO LQ-SALT LQ-NO-WORLD-SEED LQ-NO-SEQUENCE-ID LQ-COUNT
     MOVE "Alice" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-ROW
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-ROW)) + 3
     COMPUTE WS-BY = FUNCTION INTEGER(PL-Y(WS-ROW))
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-ROW))
     MOVE CB-DEFAULT-STATE(CR-GREYSTONE + 1) TO WS-STONE
     MOVE "minecraft:chest" TO WS-KEY
     CALL "TEST-BLOCK-ID" USING WS-KEY WS-ID
     MOVE CB-FIRST-STATE(WS-ID + 1) TO WS-FIRST-STATE
     PERFORM PREPARE-GROUND

*>   A chest with c_split and seed 12345 is filled at its first open; the key is cleared; the next draw of the context random is 555.
     MOVE WS-BX TO WS-X
     MOVE "test:c_split" TO WS-TABLE
     MOVE 12 TO WS-LEN
     MOVE 12345 TO WS-SEED
     PERFORM MAKE-CHEST
     MOVE "test be loot fill given a chest with a loot table and a seed when it is opened then the slots hold the model's stacks, "
         & "the key is cleared and the fill drew the model's random numbers" TO TL-CASE
     CALL "MENU-CONT-OPEN" USING WS-CONN WS-X WS-BY WS-BZ WS-OPENED
     PERFORM DESCRIBE-SLOTS
     CALL "LOOT-RNG-INT" USING WS-BOUND WS-PROBE
     MOVE WS-PROBE TO WS-E3
     MOVE BE-LOOT-LENGTH(WS-BE) TO WS-E2
     STRING FUNCTION TRIM(WS-TEXT) " key " FUNCTION TRIM(WS-E2) " probe " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "0:5x7 12:5x1 16:5x1 20:3x1 22:5x1 key 0 probe 555" TO TL-EXPECTED
     PERFORM CHECK

*>   The second open does not fill again.
     MOVE "test be loot fill given a chest already filled when it is opened again then the slots are unchanged" TO TL-CASE
     CALL "MENU-CONT-OPEN" USING WS-CONN WS-X WS-BY WS-BZ WS-OPENED
     PERFORM DESCRIBE-SLOTS
     MOVE "0:5x7 12:5x1 16:5x1 20:3x1 22:5x1" TO TL-EXPECTED
     PERFORM CHECK

*>   c_mixed has weighted draws before the fill.
     ADD 2 TO WS-BZ
     PERFORM PREPARE-GROUND
     MOVE WS-BX TO WS-X
     MOVE "test:c_mixed" TO WS-TABLE
     MOVE 12 TO WS-LEN
     MOVE 777 TO WS-SEED
     PERFORM MAKE-CHEST
     MOVE "test be loot fill given a table with weighted entries and a seed when the chest is opened then the slots hold the model's stacks"
         TO TL-CASE
     CALL "MENU-CONT-OPEN" USING WS-CONN WS-X WS-BY WS-BZ WS-OPENED
     PERFORM DESCRIBE-SLOTS
     CALL "LOOT-RNG-INT" USING WS-BOUND WS-PROBE
     MOVE WS-PROBE TO WS-E3
     STRING FUNCTION TRIM(WS-TEXT) " probe " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "4:4x3 5:4x1 17:4x3 19:5x1 21:5x1 26:4x1 probe 734" TO TL-EXPECTED
     PERFORM CHECK

*>   A negative seed.
     ADD 2 TO WS-BZ
     PERFORM PREPARE-GROUND
     MOVE WS-BX TO WS-X
     MOVE "test:c_split" TO WS-TABLE
     MOVE 12 TO WS-LEN
     MOVE -42 TO WS-SEED
     PERFORM MAKE-CHEST
     MOVE "test be loot fill given a negative seed when the chest is opened then the slots hold the model's stacks" TO TL-CASE
     CALL "MENU-CONT-OPEN" USING WS-CONN WS-X WS-BY WS-BZ WS-OPENED
     PERFORM DESCRIBE-SLOTS
     CALL "LOOT-RNG-INT" USING WS-BOUND WS-PROBE
     MOVE WS-PROBE TO WS-E3
     STRING FUNCTION TRIM(WS-TEXT) " probe " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "2:5x1 12:5x1 14:5x1 15:5x3 16:3x1 18:5x4 probe 310" TO TL-EXPECTED
     PERFORM CHECK

*>   Seed 0: the level's random; two stacks of count 1, in two of the 27 slots.
     ADD 2 TO WS-BZ
     PERFORM PREPARE-GROUND
     MOVE WS-BX TO WS-X
     MOVE "test:c_fixed" TO WS-TABLE
     MOVE 12 TO WS-LEN
     MOVE 0 TO WS-SEED
     PERFORM MAKE-CHEST
     MOVE "test be loot fill given a seed of 0 when the chest is opened then the two stacks of the table are in the slots" TO TL-CASE
     CALL "MENU-CONT-OPEN" USING WS-CONN WS-X WS-BY WS-BZ WS-OPENED
     PERFORM COUNT-SLOTS
     MOVE WS-S TO WS-E1
     MOVE FUNCTION TRIM(WS-E1) TO WS-TEXT
     MOVE "2" TO TL-EXPECTED
     PERFORM CHECK

*>   A table with as many stacks as slots: no split, the stack above 1 stays whole (the split list is appended to the list).
     ADD 2 TO WS-BZ
     PERFORM PREPARE-GROUND
     MOVE WS-BX TO WS-X
     MOVE "test:c_full" TO WS-TABLE
     MOVE 11 TO WS-LEN
     MOVE 31337 TO WS-SEED
     PERFORM MAKE-CHEST
     MOVE "test be loot fill given a table with one stack per slot and a stack above 1 when the chest is opened then every slot is "
         & "filled and the large stack was not split" TO TL-CASE
     CALL "MENU-CONT-OPEN" USING WS-CONN WS-X WS-BY WS-BZ WS-OPENED
     PERFORM DESCRIBE-SLOTS
     CALL "LOOT-RNG-INT" USING WS-BOUND WS-PROBE
     MOVE WS-PROBE TO WS-E3
     MOVE WS-TEXT TO WS-PREV
     MOVE SPACES TO WS-TEXT
     STRING FUNCTION TRIM(WS-PREV) " probe " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "0:3x1 1:3x1 2:3x1 3:3x1 4:3x1 5:3x1 6:3x1 7:3x1 8:3x1 9:3x1 10:3x1 11:3x1 12:3x1 13:3x1 14:3x1 15:3x1 16:5x5 17:3x1 18:3x1 19:3x1 20:3x1 21:3x1 22:3x1 23:3x1 24:3x1 25:3x1 26:3x1 probe 379" TO TL-EXPECTED
     PERFORM CHECK

*>   A table the open set does not hold: nothing is put in, the key is cleared.
     ADD 4 TO WS-BZ
     PERFORM PREPARE-GROUND
     MOVE WS-BX TO WS-X
     MOVE "minecraft:chests/simple_dungeon" TO WS-TABLE
     MOVE 31 TO WS-LEN
     MOVE 5 TO WS-SEED
     PERFORM MAKE-CHEST
     MOVE "test be loot fill given a table the content set does not hold when the chest is opened then it stays empty and the key is cleared"
         TO TL-CASE
     CALL "MENU-CONT-OPEN" USING WS-CONN WS-X WS-BY WS-BZ WS-OPENED
     PERFORM COUNT-SLOTS
     MOVE WS-S TO WS-E1
     MOVE BE-LOOT-LENGTH(WS-BE) TO WS-E2
     MOVE SPACES TO WS-TEXT
     STRING "slots " FUNCTION TRIM(WS-E1) " key " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "slots 0 key 0" TO TL-EXPECTED
     PERFORM CHECK

*>   A double chest: both halves are filled when it is opened.
     ADD 2 TO WS-BZ
     PERFORM PREPARE-GROUND
     MOVE WS-BX TO WS-X
     COMPUTE WS-STATE = WS-FIRST-STATE + 3
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-BY WS-BZ WS-STATE
     CALL "TEST-BE-AT" USING WS-DIM WS-X WS-BY WS-BZ WS-BE
     COMPUTE WS-X = WS-BX + 1
     COMPUTE WS-STATE = WS-FIRST-STATE + 5
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-BY WS-BZ WS-STATE
     CALL "TEST-BE-AT" USING WS-DIM WS-X WS-BY WS-BZ WS-BE2
     MOVE "test:c_fixed" TO BE-LOOT(WS-BE)
     MOVE 12 TO BE-LOOT-LENGTH(WS-BE)
     MOVE 0 TO BE-SEED(WS-BE)
     MOVE "test:c_fixed" TO BE-LOOT(WS-BE2)
     MOVE 12 TO BE-LOOT-LENGTH(WS-BE2)
     MOVE 0 TO BE-SEED(WS-BE2)
     MOVE "test be loot fill given a double chest with a loot table in each half when it is opened then both halves are filled" TO TL-CASE
     CALL "MENU-CONT-OPEN" USING WS-CONN WS-BX WS-BY WS-BZ WS-OPENED
     MOVE 0 TO WS-S
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 27
         IF BE-SLOT-COUNT(WS-BE, WS-I) > 0
             ADD 1 TO WS-S
         END-IF
         IF BE-SLOT-COUNT(WS-BE2, WS-I) > 0
             ADD 10 TO WS-S
         END-IF
     END-PERFORM
     MOVE WS-S TO WS-E1
     MOVE SPACES TO WS-TEXT
     MOVE FUNCTION TRIM(WS-E1) TO WS-TEXT
     MOVE "22" TO TL-EXPECTED
     PERFORM CHECK

*>   Breaking: the contents are rolled first, then dropped (two stacks, two item entities).
     ADD 2 TO WS-BZ
     PERFORM PREPARE-GROUND
     MOVE WS-BX TO WS-X
     MOVE "test:c_fixed" TO WS-TABLE
     MOVE 12 TO WS-LEN
     MOVE 9 TO WS-SEED
     PERFORM MAKE-CHEST
     PERFORM COUNT-ITEMS
     MOVE WS-S TO WS-BEFORE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-BY WS-BZ WS-AIR
     PERFORM COUNT-ITEMS
     MOVE WS-S TO WS-AFTER
     COMPUTE WS-E1 = WS-AFTER - WS-BEFORE
     MOVE SPACES TO WS-TEXT
     MOVE FUNCTION TRIM(WS-E1) TO WS-TEXT
     MOVE "test be loot fill given a chest with a loot table when the block is broken then its stacks drop as item entities" TO TL-CASE
     MOVE "2" TO TL-EXPECTED
     PERFORM CHECK
     GOBACK.

 PREPARE-GROUND.
     COMPUTE WS-Y = WS-BY - 1
     PERFORM VARYING WS-X FROM WS-BX BY 1 UNTIL WS-X > WS-BX + 3
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-BZ WS-STONE
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-BY WS-BZ WS-AIR
     END-PERFORM.

 MAKE-CHEST.
     COMPUTE WS-STATE = WS-FIRST-STATE + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-BY WS-BZ WS-STATE
     CALL "TEST-BE-AT" USING WS-DIM WS-X WS-BY WS-BZ WS-BE
     MOVE WS-TABLE TO BE-LOOT(WS-BE)
     MOVE WS-LEN TO BE-LOOT-LENGTH(WS-BE)
     MOVE WS-SEED TO BE-SEED(WS-BE).

 DESCRIBE-SLOTS.
     MOVE SPACES TO WS-TEXT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 27
         IF BE-SLOT-COUNT(WS-BE, WS-I) > 0
             COMPUTE WS-S = WS-I - 1
             MOVE WS-S TO WS-E1
             MOVE BE-SLOT-ITEM(WS-BE, WS-I) TO WS-E2
             MOVE BE-SLOT-COUNT(WS-BE, WS-I) TO WS-E3
             MOVE WS-TEXT TO WS-PREV
             MOVE SPACES TO WS-TEXT
             STRING FUNCTION TRIM(WS-PREV TRAILING) " " FUNCTION TRIM(WS-E1) ":" FUNCTION TRIM(WS-E2) "x" FUNCTION TRIM(WS-E3)
                 DELIMITED BY SIZE INTO WS-TEXT
         END-IF
     END-PERFORM.

 COUNT-SLOTS.
     MOVE 0 TO WS-S
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 27
         IF BE-SLOT-COUNT(WS-BE, WS-I) > 0
             ADD 1 TO WS-S
         END-IF
     END-PERFORM.

 COUNT-ITEMS.
     MOVE 0 TO WS-S
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = CR-LOOSE-ITEM
             ADD 1 TO WS-S
         END-IF
     END-PERFORM.

 CHECK.
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-BE-LOOT-FILL.

 COPY CORETEST.
 COPY BETEST.
