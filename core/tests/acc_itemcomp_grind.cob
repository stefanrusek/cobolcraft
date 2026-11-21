*> Acceptance test, the grindstone as a live menu through the real play path (docs/protocol/40-menus-3 section 4; lane itemcomp3, T10604): Use Item On opens family 22 (3 own slots, result 2), a
*> shift click puts a sword with sharpness 3 and a curse (smite stands in for it) into an input, the result keeps only the curse, a plain pickaxe is refused by the input slots, taking the result
*> awards the experience of the sharpness (12 to 23 points as orbs) and empties both inputs.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-ITEMCOMP-GRIND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CMENU.
 COPY CBLOCKS.
 COPY COREAPI.
 COPY CONTENT.
 COPY PLAYPKT.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/anvil-registry".
 01 WS-REG-STATUS          BINARY-LONG.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-FACE                BINARY-LONG VALUE 1.
 01 WS-SEQ                 BINARY-LONG VALUE 0.
 01 WS-KEY                 PIC X(48).
 01 WS-ID                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-SHELF               BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-TABLE               BINARY-LONG.
 01 WS-SWORD               BINARY-LONG.
 01 WS-SHOVEL              BINARY-LONG.
 01 WS-BOOK                BINARY-LONG.
 01 WS-EBOOK               BINARY-LONG.
 01 WS-LAPIS               BINARY-LONG.
 01 WS-IDS                 PIC X(1024).
 01 WS-BUTTON              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-REGI                PIC X(48).
 01 WS-TAGKEY              PIC X(112).
 01 WS-TIDS.
    05 WS-MEMBER           BINARY-LONG OCCURS 8 TIMES.
 01 WS-N2                  BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-SHARP               BINARY-LONG.
 01 WS-SMITE               BINARY-LONG.
 01 WS-KEY64               PIC X(64).
 01 WS-KEYLEN              BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-TAG                 PIC X(112).
 01 WS-TAGLEN              BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-TX                  BINARY-LONG.
 01 WS-TY                  BINARY-LONG.
 01 WS-TZ                  BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-B2                  BINARY-LONG.
 01 WS-C0                  BINARY-LONG.
 01 WS-C1                  BINARY-LONG.
 01 WS-C2                  BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-LEV                 BINARY-LONG.
 01 WS-SEED                BINARY-LONG.
 01 WS-OLD-SEED            BINARY-LONG.
 01 WS-TYPE13              BINARY-LONG VALUE 13.
 01 WS-TYPE45              BINARY-LONG VALUE 45.
 01 WS-CNT                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-CNT2                BINARY-LONG.
 01 WS-RET                 BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-E4                  PIC -(9)9.
 01 WS-E5                  PIC -(9)9.
 01 WS-E6                  PIC -(9)9.
 01 WS-TEXT                PIC X(256).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-DEFAULT-MODE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE CT-TYPE-COBOLCRAFT TO CT-SET-TYPE
     CALL "REGISTRY-LOAD-ALL" USING WS-DIR WS-REG-STATUS
     MOVE "Alice" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     CALL "TEST-STANDARD-TABLES"
     MOVE CN-PLAYER(WS-CONN) TO WS-ROW
     MOVE 0 TO PL-YAW(WS-ROW) PL-PITCH(WS-ROW)
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-ROW)) + 2
     COMPUTE WS-BY = FUNCTION INTEGER(PL-Y(WS-ROW))
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-ROW))
     MOVE "stone" TO WS-KEY
     CALL "TEST-BLOCK-ID" USING WS-KEY WS-ID
     MOVE CB-DEFAULT-STATE(WS-ID + 1) TO WS-STONE
     MOVE "bookshelf" TO WS-KEY
     CALL "TEST-BLOCK-ID" USING WS-KEY WS-ID
     MOVE CB-DEFAULT-STATE(WS-ID + 1) TO WS-SHELF
     MOVE WS-ID TO WS-MEMBER(1)
     MOVE "block" TO WS-REGI
     MOVE "minecraft:enchantment_power_provider" TO WS-TAGKEY
     MOVE 1 TO WS-N2
     CALL "TAG-PUT" USING WS-REGI WS-TAGKEY WS-N2 WS-TIDS WS-STATUS
     MOVE "air" TO WS-KEY
     CALL "TEST-BLOCK-ID" USING WS-KEY WS-ID
     MOVE WS-ID TO WS-MEMBER(1)
     MOVE "minecraft:enchantment_power_transmitter" TO WS-TAGKEY
     CALL "TAG-PUT" USING WS-REGI WS-TAGKEY WS-N2 WS-TIDS WS-STATUS
     MOVE "grindstone" TO WS-KEY
     CALL "TEST-BLOCK-ID" USING WS-KEY WS-ID
     MOVE CB-DEFAULT-STATE(WS-ID + 1) TO WS-TABLE
     MOVE "diamond_sword" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-SWORD
     MOVE "diamond_shovel" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-SHOVEL
     MOVE "book" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-BOOK
     MOVE "enchanted_book" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-EBOOK
     MOVE "lapis_lazuli" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-LAPIS
*>   The enchantments and their tags (the fixture's rows): the sword takes sharpness and smite (exclusive) and unbreaking.
     MOVE "minecraft:sharpness" TO WS-KEY64
     MOVE 19 TO WS-KEYLEN
     CALL "CXB-ENCH-DEF" USING WS-KEY64 WS-KEYLEN WS-SHARP WS-MAX WS-TAG WS-TAGLEN
     MOVE "minecraft:smite" TO WS-KEY64
     MOVE 15 TO WS-KEYLEN
     CALL "CXB-ENCH-DEF" USING WS-KEY64 WS-KEYLEN WS-SMITE WS-MAX WS-TAG WS-TAGLEN
     MOVE "item" TO WS-REGI
     MOVE WS-SWORD TO WS-MEMBER(1)
     MOVE 1 TO WS-N2
     MOVE "minecraft:enchantable/sharp_weapon" TO WS-TAGKEY
     CALL "TAG-PUT" USING WS-REGI WS-TAGKEY WS-N2 WS-TIDS WS-STATUS
     MOVE "enchantment" TO WS-REGI
     MOVE WS-SHARP TO WS-MEMBER(1)
     MOVE WS-SMITE TO WS-MEMBER(2)
     MOVE 2 TO WS-N2
     MOVE "minecraft:exclusive_set/damage" TO WS-TAGKEY
     CALL "TAG-PUT" USING WS-REGI WS-TAGKEY WS-N2 WS-TIDS WS-STATUS
     MOVE "minecraft:in_enchanting_table" TO WS-TAGKEY
     CALL "TAG-PUT" USING WS-REGI WS-TAGKEY WS-N2 WS-TIDS WS-STATUS
     PERFORM PREPARE-GROUND
     MOVE "T" TO TL-MODE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
         MOVE 0 TO PL-SLOT-COUNT(WS-ROW, WS-I) PL-SLOT-ITEM(WS-ROW, WS-I) PL-SLOT-VAR(WS-ROW, WS-I)
     END-PERFORM
     MOVE WS-TABLE TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE WS-BX TO WS-X
     MOVE WS-BY TO WS-Y
     MOVE WS-BZ TO WS-Z
     PERFORM USE-BLOCK

     MOVE "enchantment" TO WS-REGI
     MOVE WS-SMITE TO WS-MEMBER(1)
     MOVE 1 TO WS-N2
     MOVE "minecraft:curse" TO WS-TAGKEY
     CALL "TAG-PUT" USING WS-REGI WS-TAGKEY WS-N2 WS-TIDS WS-STATUS
     MOVE "iron_pickaxe" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-SHOVEL

     MOVE "acceptance itemcomp grind open: Use Item On the grindstone opens family 22 of 3 own slots, the result is slot 2" TO TL-CASE
     MOVE MN-CFAMILY(WS-ROW) TO WS-E1
     MOVE MN-CSIZE(WS-ROW) TO WS-E2
     MOVE MN-WRES(WS-ROW) TO WS-E3
     MOVE SPACES TO WS-TEXT
     STRING "family " FUNCTION TRIM(WS-E1) " size " FUNCTION TRIM(WS-E2) " result " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "family 22 size 3 result 2" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance itemcomp grind input rules: a plain iron pickaxe (damageable) goes in by a shift click, a stack of dirt does not" TO TL-CASE
     MOVE WS-SHOVEL TO PL-SLOT-ITEM(WS-ROW, 1)
     MOVE 1 TO PL-SLOT-COUNT(WS-ROW, 1)
     MOVE 0 TO PL-SLOT-VAR(WS-ROW, 1)
     MOVE "dirt" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-ID
     MOVE WS-ID TO PL-SLOT-ITEM(WS-ROW, 2)
     MOVE 5 TO PL-SLOT-COUNT(WS-ROW, 2)
     MOVE 0 TO PL-SLOT-VAR(WS-ROW, 2)
     MOVE 0 TO WS-BUTTON
     MOVE 1 TO WS-TYPE
     MOVE 30 TO WS-S
     CALL "TEST-CLICK-WIN" USING WS-CONN WS-S WS-BUTTON WS-TYPE
     MOVE 31 TO WS-S
     CALL "TEST-CLICK-WIN" USING WS-CONN WS-S WS-BUTTON WS-TYPE
     MOVE MN-WSLOT-COUNT(WS-ROW, 1) TO WS-E1
     MOVE MN-WSLOT-COUNT(WS-ROW, 2) TO WS-E2
     MOVE PL-SLOT-COUNT(WS-ROW, 2) TO WS-E3
     MOVE MN-RESULT-COUNT(WS-ROW) TO WS-E4
     MOVE SPACES TO WS-TEXT
     STRING "inputs " FUNCTION TRIM(WS-E1) "/" FUNCTION TRIM(WS-E2) " dirt-left " FUNCTION TRIM(WS-E3) " result " FUNCTION TRIM(WS-E4)
         DELIMITED BY SIZE INTO WS-TEXT
     MOVE "inputs 1/0 dirt-left 5 result 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance itemcomp grind result: the pickaxe is replaced by a sword with sharpness 3 and smite 1 in an input; the result keeps smite 1 and nothing else" TO TL-CASE
     MOVE 0 TO MN-WSLOT-COUNT(WS-ROW, 1) MN-WSLOT-ITEM(WS-ROW, 1) MN-WSLOT-VAR(WS-ROW, 1)
     MOVE 0 TO WS-CNT
     MOVE 3 TO WS-LEV
     CALL "SC-ENCH-ADD" USING WS-CNT WS-TYPE13 WS-SHARP WS-LEV
     MOVE 1 TO WS-LEV
     CALL "SC-ENCH-ADD" USING WS-CNT WS-TYPE13 WS-SMITE WS-LEV
     MOVE WS-SWORD TO PL-SLOT-ITEM(WS-ROW, 1)
     MOVE 1 TO PL-SLOT-COUNT(WS-ROW, 1)
     MOVE WS-CNT TO PL-SLOT-VAR(WS-ROW, 1)
     MOVE 0 TO WS-BUTTON
     MOVE 1 TO WS-TYPE
     MOVE 30 TO WS-S
     CALL "TEST-CLICK-WIN" USING WS-CONN WS-S WS-BUTTON WS-TYPE
     CALL "SC-ENCH-COUNT" USING MN-RESULT-VAR(WS-ROW) WS-TYPE13 WS-CNT2
     CALL "SC-ENCH-LEVEL" USING MN-RESULT-VAR(WS-ROW) WS-TYPE13 WS-SMITE WS-LEV
     MOVE MN-RESULT-COUNT(WS-ROW) TO WS-E1
     MOVE WS-CNT2 TO WS-E2
     MOVE WS-LEV TO WS-E3
     MOVE MN-WSLOT-COUNT(WS-ROW, 2) TO WS-E4
     MOVE SPACES TO WS-TEXT
     STRING "result " FUNCTION TRIM(WS-E1) " pairs " FUNCTION TRIM(WS-E2) " smite " FUNCTION TRIM(WS-E3) " other " FUNCTION TRIM(WS-E4)
         DELIMITED BY SIZE INTO WS-TEXT
     MOVE "result 1 pairs 1 smite 1 other 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance itemcomp grind take: a click on the result slot gives the stripped sword, both inputs are empty and 12 to 23 points of orbs were awarded" TO TL-CASE
     MOVE 0 TO WS-BUTTON WS-TYPE
     MOVE 2 TO WS-S
     CALL "TEST-CLICK-WIN" USING WS-CONN WS-S WS-BUTTON WS-TYPE
     CALL "XP-ORB-TYPE" USING WS-TYPE
     MOVE 0 TO WS-CNT2
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-TYPE
             COMPUTE WS-CNT2 = WS-CNT2 + EN-ITEM(WS-I) * EN-ITEM-COUNT(WS-I)
         END-IF
     END-PERFORM
     MOVE PL-CARRIED-COUNT(WS-ROW) TO WS-E1
     MOVE MN-WSLOT-COUNT(WS-ROW, 1) TO WS-E2
     MOVE MN-WSLOT-COUNT(WS-ROW, 2) TO WS-E3
     MOVE 0 TO WS-I
     IF WS-CNT2 >= 12 AND WS-CNT2 <= 23
         MOVE 1 TO WS-I
     END-IF
     MOVE WS-I TO WS-E4
     MOVE MN-RESULT-COUNT(WS-ROW) TO WS-E5
     MOVE SPACES TO WS-TEXT
     STRING "cursor " FUNCTION TRIM(WS-E1) " inputs " FUNCTION TRIM(WS-E2) "/" FUNCTION TRIM(WS-E3) " xp-ok " FUNCTION TRIM(WS-E4) " result " FUNCTION TRIM(WS-E5)
         DELIMITED BY SIZE INTO WS-TEXT
     MOVE "cursor 1 inputs 0/0 xp-ok 1 result 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance itemcomp grind quick: a shift click of the result slot is not needed; a shift click of an input returns it to the inventory" TO TL-CASE
     MOVE WS-SWORD TO MN-WSLOT-ITEM(WS-ROW, 1)
     MOVE 1 TO MN-WSLOT-COUNT(WS-ROW, 1)
     MOVE 0 TO MN-WSLOT-VAR(WS-ROW, 1)
     CALL "MENU-STATION-UPDATE" USING WS-ROW
     MOVE 1 TO WS-TYPE
     MOVE 0 TO WS-S
     CALL "TEST-CLICK-WIN" USING WS-CONN WS-S WS-BUTTON WS-TYPE
     MOVE MN-WSLOT-COUNT(WS-ROW, 1) TO WS-E1
     MOVE 0 TO WS-CNT2
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
         IF PL-SLOT-ITEM(WS-ROW, WS-I) = WS-SWORD AND PL-SLOT-COUNT(WS-ROW, WS-I) > 0
             ADD 1 TO WS-CNT2
         END-IF
     END-PERFORM
     MOVE WS-CNT2 TO WS-E2
     MOVE SPACES TO WS-TEXT
     STRING "input " FUNCTION TRIM(WS-E1) " swords " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "input 0 swords 1" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

 PREPARE-GROUND.
     COMPUTE WS-Y = WS-BY - 1
     COMPUTE WS-X0 = WS-BX - 3
     COMPUTE WS-X1 = WS-BX + 3
     COMPUTE WS-Z0 = WS-BZ - 3
     COMPUTE WS-Z1 = WS-BZ + 3
     PERFORM VARYING WS-X FROM WS-X0 BY 1 UNTIL WS-X > WS-X1
         PERFORM VARYING WS-Z FROM WS-Z0 BY 1 UNTIL WS-Z > WS-Z1
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STONE
             PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 2
                 COMPUTE WS-S = WS-BY + WS-I
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-S WS-Z WS-AIR
             END-PERFORM
         END-PERFORM
     END-PERFORM.

 USE-BLOCK.
     ADD 1 TO WS-SEQ
     CALL "TEST-USE-ON" USING WS-CONN WS-X WS-Y WS-Z WS-FACE WS-SEQ
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS.

 CHECK.
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-ITEMCOMP-GRIND.

 COPY CORETEST.
 COPY BETEST.
