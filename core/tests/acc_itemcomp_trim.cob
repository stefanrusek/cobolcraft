*> Acceptance test, a smithing_trim recipe on the smithing table through the real play path (docs/protocol/27 section 3.3, 54 section 18.6, 40-3 section 5; lane itemcomp3, T10605): the template, a
*> diamond helmet and a gold ingot go to their slots by shift clicks, the result is a helmet whose trim component holds the gold material and the coast pattern, taking it uses one of each input,
*> the same trim applied to the trimmed helmet gives no result and raises the error flag (data slot 0), an iron ingot replaces the trim.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-ITEMCOMP-TRIM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CMENU.
 COPY CBLOCKS.
 COPY COREAPI.
 COPY CONTENT.
 COPY PLAYPKT.
 COPY CTRECIPE.
 01 WS-TEMPLATE            BINARY-LONG.
 01 WS-HELMET              BINARY-LONG.
 01 WS-GOLD                BINARY-LONG.
 01 WS-IRON                BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
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
     MOVE "smithing_table" TO WS-KEY
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

     PERFORM LOAD-RECIPES
     MOVE "coast_armor_trim_smithing_template" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-TEMPLATE
     MOVE "diamond_helmet" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-HELMET
     MOVE "gold_ingot" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-GOLD
     MOVE "iron_ingot" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-IRON

     MOVE "acceptance itemcomp trim inputs: shift clicks send the template, the helmet and the gold ingot to their slots; the result is the helmet with trim 4 (gold) and 1 (coast)" TO TL-CASE
     MOVE WS-TEMPLATE TO PL-SLOT-ITEM(WS-ROW, 1)
     MOVE 1 TO PL-SLOT-COUNT(WS-ROW, 1)
     MOVE WS-HELMET TO PL-SLOT-ITEM(WS-ROW, 2)
     MOVE 1 TO PL-SLOT-COUNT(WS-ROW, 2)
     MOVE WS-GOLD TO PL-SLOT-ITEM(WS-ROW, 3)
     MOVE 2 TO PL-SLOT-COUNT(WS-ROW, 3)
     MOVE 0 TO WS-BUTTON
     MOVE 1 TO WS-TYPE
     PERFORM VARYING WS-S FROM 31 BY 1 UNTIL WS-S > 33
         CALL "TEST-CLICK-WIN" USING WS-CONN WS-S WS-BUTTON WS-TYPE
     END-PERFORM
     CALL "SC-TRIM-GET" USING MN-RESULT-VAR(WS-ROW) WS-OK WS-M WS-P
     MOVE MN-RESULT-COUNT(WS-ROW) TO WS-E1
     MOVE WS-M TO WS-E2
     MOVE WS-P TO WS-E3
     MOVE 0 TO WS-E4
     IF MN-RESULT-ITEM(WS-ROW) = WS-HELMET
         MOVE 1 TO WS-E4
     END-IF
     MOVE MN-WDATA(WS-ROW, 1) TO WS-E5
     MOVE SPACES TO WS-TEXT
     STRING "result " FUNCTION TRIM(WS-E1) " helmet " FUNCTION TRIM(WS-E4) " trim " FUNCTION TRIM(WS-E2) "/" FUNCTION TRIM(WS-E3) " flag " FUNCTION TRIM(WS-E5)
         DELIMITED BY SIZE INTO WS-TEXT
     MOVE "result 1 helmet 1 trim 4/1 flag 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance itemcomp trim take: a click on the result slot gives the trimmed helmet and uses the template, the helmet and one gold ingot" TO TL-CASE
     MOVE 0 TO WS-BUTTON WS-TYPE
     MOVE 3 TO WS-S
     CALL "TEST-CLICK-WIN" USING WS-CONN WS-S WS-BUTTON WS-TYPE
     CALL "SC-TRIM-GET" USING PL-CARRIED-VAR(WS-ROW) WS-OK WS-M WS-P
     MOVE PL-CARRIED-COUNT(WS-ROW) TO WS-E1
     MOVE WS-M TO WS-E2
     MOVE MN-WSLOT-COUNT(WS-ROW, 1) TO WS-E3
     MOVE MN-WSLOT-COUNT(WS-ROW, 2) TO WS-E4
     MOVE MN-WSLOT-COUNT(WS-ROW, 3) TO WS-E5
     MOVE SPACES TO WS-TEXT
     STRING "cursor " FUNCTION TRIM(WS-E1) " trim " FUNCTION TRIM(WS-E2) " inputs " FUNCTION TRIM(WS-E3) "/" FUNCTION TRIM(WS-E4) "/" FUNCTION TRIM(WS-E5)
         DELIMITED BY SIZE INTO WS-TEXT
     MOVE "cursor 1 trim 4 inputs 0/0/1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance itemcomp trim again: the trimmed helmet with the template and gold gives no result and sets the error flag; iron makes a result with material 5" TO TL-CASE
     MOVE WS-TEMPLATE TO MN-WSLOT-ITEM(WS-ROW, 1)
     MOVE 1 TO MN-WSLOT-COUNT(WS-ROW, 1)
     MOVE PL-CARRIED-ITEM(WS-ROW) TO MN-WSLOT-ITEM(WS-ROW, 2)
     MOVE 1 TO MN-WSLOT-COUNT(WS-ROW, 2)
     MOVE PL-CARRIED-VAR(WS-ROW) TO MN-WSLOT-VAR(WS-ROW, 2)
     MOVE 0 TO PL-CARRIED-COUNT(WS-ROW)
     CALL "MENU-STATION-UPDATE" USING WS-ROW
     MOVE MN-RESULT-COUNT(WS-ROW) TO WS-E1
     MOVE MN-WDATA(WS-ROW, 1) TO WS-E2
     MOVE WS-IRON TO MN-WSLOT-ITEM(WS-ROW, 3)
     MOVE 1 TO MN-WSLOT-COUNT(WS-ROW, 3)
     CALL "MENU-STATION-UPDATE" USING WS-ROW
     CALL "SC-TRIM-GET" USING MN-RESULT-VAR(WS-ROW) WS-OK WS-M WS-P
     MOVE MN-RESULT-COUNT(WS-ROW) TO WS-E3
     MOVE WS-M TO WS-E4
     MOVE SPACES TO WS-TEXT
     STRING "same " FUNCTION TRIM(WS-E1) " flag " FUNCTION TRIM(WS-E2) " iron " FUNCTION TRIM(WS-E3) "/" FUNCTION TRIM(WS-E4) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "same 0 flag 1 iron 1/5" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

 LOAD-RECIPES.
     MOVE 2 TO RC-COUNT
     INITIALIZE RC-ROW(1) RC-ROW(2)
     MOVE 21 TO RR-SERIALIZER(1) RR-SERIALIZER(2)
     MOVE "minecraft:coast_armor_trim_smithing_template" TO RR-ING(1, 1)
     MOVE "minecraft:diamond_helmet" TO RR-ING(1, 2)
     MOVE "minecraft:gold_ingot" TO RR-ING(1, 3)
     MOVE "minecraft:coast" TO RR-EXTRA(1)
     MOVE "minecraft:coast_armor_trim_smithing_template" TO RR-ING(2, 1)
     MOVE "minecraft:diamond_helmet" TO RR-ING(2, 2)
     MOVE "minecraft:iron_ingot" TO RR-ING(2, 3)
     MOVE "minecraft:coast" TO RR-EXTRA(2).

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
 END PROGRAM ACC-ITEMCOMP-TRIM.

 COPY CORETEST.
 COPY BETEST.
