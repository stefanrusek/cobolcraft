*> Acceptance test, the enchanting table as a live menu through the real play path (docs/protocol/40-menus-4 section 2, 17 section 6.5; lane itemcomp3, T10601): Use Item On opens the table
*> (family 27, 2 own slots, no result slot, type 13), the data slots start at costs 0 and clues -1 with the player's seed (its low 16 bits go to the client), a shift click of a sword fills slot 0 (one
*> item), the 32 bookshelves of the ring give costs of 30 for the third option, lapis goes to its own slot, a button click pays levels and lapis and enchants the sword, a book becomes an enchanted
*> book with stored enchantments, an item the pool does not hold is offered a cost but no list, and the item slot takes one item of a carried stack.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-ITEMCOMP-ENCH.
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
     MOVE "enchanting_table" TO WS-KEY
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
     MOVE 1 TO PL-ENCH-INIT(WS-ROW)
     MOVE 40000 TO PL-ENCH-SEED(WS-ROW)
     PERFORM USE-BLOCK

     MOVE "acceptance itemcomp ench open: Use Item On the table opens family 27 of 2 own slots, type 13, no result slot; costs 0, clues -1, the player's seed 40000 in data slot 3" TO TL-CASE
     MOVE MN-CFAMILY(WS-ROW) TO WS-E1
     MOVE MN-CSIZE(WS-ROW) TO WS-E2
     MOVE MN-TYPE(WS-ROW) TO WS-E3
     MOVE MN-WDATA(WS-ROW, 4) TO WS-E4
     MOVE MN-WDATA(WS-ROW, 1) TO WS-E5
     MOVE MN-WDATA(WS-ROW, 5) TO WS-E6
     MOVE SPACES TO WS-TEXT
     STRING "family " FUNCTION TRIM(WS-E1) " size " FUNCTION TRIM(WS-E2) " type " FUNCTION TRIM(WS-E3) " seed " FUNCTION TRIM(WS-E4)
         " cost " FUNCTION TRIM(WS-E5) " clue " FUNCTION TRIM(WS-E6) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "family 27 size 2 type 13 seed 40000 cost 0 clue -1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance itemcomp ench data: the seed was sent (sent value equals the full seed), the 32 ring bookshelves count 32 and a stone at one transmitter spot makes it 31" TO TL-CASE
     MOVE MN-WSENT(WS-ROW, 4) TO WS-E1
     CALL "ENCH-SHELVES" USING WS-DIM WS-BX WS-BY WS-BZ WS-B
     MOVE WS-B TO WS-E2
     CALL "ENCH-OFFSET" USING WS-ONE WS-DX WS-DY WS-DZ WS-TX WS-TY WS-TZ
     COMPUTE WS-X = WS-BX + WS-TX
     COMPUTE WS-Y = WS-BY + WS-TY
     COMPUTE WS-Z = WS-BZ + WS-TZ
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STONE
     CALL "ENCH-SHELVES" USING WS-DIM WS-BX WS-BY WS-BZ WS-B2
     MOVE WS-B2 TO WS-E3
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-AIR
     MOVE SPACES TO WS-TEXT
     STRING "sent " FUNCTION TRIM(WS-E1) " shelves " FUNCTION TRIM(WS-E2) " blocked " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "sent 40000 shelves 32 blocked 31" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance itemcomp ench item: a shift click moves ONE sword into slot 0 and the offers appear: cost 3 of the 32 shelves is 30, every cost is above 0, the clue of option 3 is sharpness, smite or unbreaking-free pool" TO TL-CASE
     MOVE WS-SWORD TO PL-SLOT-ITEM(WS-ROW, 1)
     MOVE 1 TO PL-SLOT-COUNT(WS-ROW, 1)
     MOVE 0 TO WS-BUTTON
     MOVE 1 TO WS-TYPE
     MOVE 29 TO WS-S
     CALL "TEST-CLICK-WIN" USING WS-CONN WS-S WS-BUTTON WS-TYPE
     MOVE MN-WSLOT-COUNT(WS-ROW, 1) TO WS-E1
     MOVE MN-WDATA(WS-ROW, 3) TO WS-E2
     MOVE MN-WDATA(WS-ROW, 1) TO WS-E3
     MOVE MN-WDATA(WS-ROW, 7) TO WS-E4
     MOVE MN-WDATA(WS-ROW, 10) TO WS-E5
     MOVE SPACES TO WS-TEXT
     MOVE 0 TO WS-I
     IF MN-WDATA(WS-ROW, 7) = WS-SHARP OR MN-WDATA(WS-ROW, 7) = WS-SMITE
         MOVE 1 TO WS-I
     END-IF
     MOVE WS-I TO WS-E6
     STRING "slot " FUNCTION TRIM(WS-E1) " cost3 " FUNCTION TRIM(WS-E2) " clue-in-pool " FUNCTION TRIM(WS-E6)
         DELIMITED BY SIZE INTO WS-TEXT
     MOVE "slot 1 cost3 30 clue-in-pool 1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance itemcomp ench refusals: option 3 needs 3 lapis and 3 levels: with neither the click returns false and nothing changes" TO TL-CASE
     MOVE 2 TO PSB-BUTTON
     MOVE MN-WINDOW(WS-ROW) TO PSB-CONTAINER
     CALL "STATION-BUTTON" USING WS-CONN PLAY-SERVERBOUND
     MOVE MN-WSLOT-COUNT(WS-ROW, 1) TO WS-E1
     CALL "SC-ENCH-COUNT" USING MN-WSLOT-VAR(WS-ROW, 1) WS-TYPE13 WS-CNT
     MOVE WS-CNT TO WS-E2
     MOVE MN-WDATA(WS-ROW, 4) TO WS-E3
     MOVE SPACES TO WS-TEXT
     STRING "item " FUNCTION TRIM(WS-E1) " enchantments " FUNCTION TRIM(WS-E2) " seed " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "item 1 enchantments 0 seed 40000" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance itemcomp ench lapis: a shift click of 3 lapis goes to the lapis slot only; a shift click of an item does not go there while slot 0 is full" TO TL-CASE
     MOVE WS-LAPIS TO PL-SLOT-ITEM(WS-ROW, 2)
     MOVE 3 TO PL-SLOT-COUNT(WS-ROW, 2)
     MOVE WS-SHOVEL TO PL-SLOT-ITEM(WS-ROW, 3)
     MOVE 1 TO PL-SLOT-COUNT(WS-ROW, 3)
     MOVE 30 TO WS-S
     CALL "TEST-CLICK-WIN" USING WS-CONN WS-S WS-BUTTON WS-TYPE
     MOVE 31 TO WS-S
     CALL "TEST-CLICK-WIN" USING WS-CONN WS-S WS-BUTTON WS-TYPE
     MOVE MN-WSLOT-COUNT(WS-ROW, 2) TO WS-E1
     MOVE MN-WSLOT-ITEM(WS-ROW, 2) TO WS-E2
     MOVE PL-SLOT-COUNT(WS-ROW, 3) TO WS-E3
     MOVE SPACES TO WS-TEXT
     MOVE WS-LAPIS TO WS-E4
     STRING "lapis " FUNCTION TRIM(WS-E1) " is-lapis " FUNCTION TRIM(WS-E2) "/" FUNCTION TRIM(WS-E4) " shovel-left " FUNCTION TRIM(WS-E3)
         DELIMITED BY SIZE INTO WS-TEXT
     STRING "lapis 3 is-lapis " FUNCTION TRIM(WS-E4) "/" FUNCTION TRIM(WS-E4) " shovel-left 1" DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance itemcomp ench without levels: with the lapis but level 2 the third option is refused" TO TL-CASE
     MOVE 2 TO PL-XP-LEVEL(WS-ROW)
     CALL "STATION-BUTTON" USING WS-CONN PLAY-SERVERBOUND
     CALL "SC-ENCH-COUNT" USING MN-WSLOT-VAR(WS-ROW, 1) WS-TYPE13 WS-CNT
     MOVE WS-CNT TO WS-E1
     MOVE MN-WSLOT-COUNT(WS-ROW, 2) TO WS-E2
     MOVE SPACES TO WS-TEXT
     STRING "enchantments " FUNCTION TRIM(WS-E1) " lapis " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "enchantments 0 lapis 3" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance itemcomp ench enchant: with 30 levels the third option takes 3 levels and the 3 lapis, the sword has enchantments, the seed is renewed and the offers are gone" TO TL-CASE
     MOVE 40000 TO WS-OLD-SEED
     MOVE 30 TO PL-XP-LEVEL(WS-ROW)
     CALL "STATION-BUTTON" USING WS-CONN PLAY-SERVERBOUND
     CALL "SC-ENCH-COUNT" USING MN-WSLOT-VAR(WS-ROW, 1) WS-TYPE13 WS-CNT
     MOVE WS-CNT TO WS-E1
     MOVE PL-XP-LEVEL(WS-ROW) TO WS-E2
     MOVE MN-WSLOT-COUNT(WS-ROW, 2) TO WS-E3
     MOVE 0 TO WS-I
     IF MN-WDATA(WS-ROW, 4) NOT = WS-OLD-SEED AND MN-WDATA(WS-ROW, 4) = PL-ENCH-SEED(WS-ROW)
         MOVE 1 TO WS-I
     END-IF
     MOVE WS-I TO WS-E4
     MOVE MN-WDATA(WS-ROW, 3) TO WS-E5
     MOVE SPACES TO WS-TEXT
     STRING "enchanted " FUNCTION TRIM(WS-E1) " levels " FUNCTION TRIM(WS-E2) " lapis " FUNCTION TRIM(WS-E3) " renewed " FUNCTION TRIM(WS-E4)
         " cost3 " FUNCTION TRIM(WS-E5) DELIMITED BY SIZE INTO WS-TEXT
     MOVE SPACES TO TL-EXPECTED
     STRING "enchanted " FUNCTION TRIM(WS-E1) " levels 27 lapis 0 renewed 1 cost3 0" DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance itemcomp ench book: a book with 3 lapis and 30 levels becomes an enchanted book with stored enchantments (and none in the enchantments component)" TO TL-CASE
     MOVE 0 TO MN-WSLOT-COUNT(WS-ROW, 1) MN-WSLOT-ITEM(WS-ROW, 1) MN-WSLOT-VAR(WS-ROW, 1)
     MOVE WS-BOOK TO MN-WSLOT-ITEM(WS-ROW, 1)
     MOVE 1 TO MN-WSLOT-COUNT(WS-ROW, 1)
     MOVE WS-LAPIS TO MN-WSLOT-ITEM(WS-ROW, 2)
     MOVE 3 TO MN-WSLOT-COUNT(WS-ROW, 2)
     MOVE 30 TO PL-XP-LEVEL(WS-ROW)
     CALL "MENU-STATION-UPDATE" USING WS-ROW
     CALL "STATION-BUTTON" USING WS-CONN PLAY-SERVERBOUND
     CALL "SC-ENCH-COUNT" USING MN-WSLOT-VAR(WS-ROW, 1) WS-TYPE45 WS-CNT
     CALL "SC-ENCH-COUNT" USING MN-WSLOT-VAR(WS-ROW, 1) WS-TYPE13 WS-CNT2
     MOVE 0 TO WS-I
     IF MN-WSLOT-ITEM(WS-ROW, 1) = WS-EBOOK
         MOVE 1 TO WS-I
     END-IF
     MOVE WS-I TO WS-E1
     MOVE 0 TO WS-I
     IF WS-CNT >= 1
         MOVE 1 TO WS-I
     END-IF
     MOVE WS-I TO WS-E2
     MOVE WS-CNT2 TO WS-E3
     MOVE MN-WSLOT-COUNT(WS-ROW, 2) TO WS-E4
     MOVE SPACES TO WS-TEXT
     STRING "ebook " FUNCTION TRIM(WS-E1) " stored " FUNCTION TRIM(WS-E2) " plain " FUNCTION TRIM(WS-E3) " lapis " FUNCTION TRIM(WS-E4)
         DELIMITED BY SIZE INTO WS-TEXT
     MOVE "ebook 1 stored 1 plain 0 lapis 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance itemcomp ench empty list: a diamond shovel (enchantable, in no pool tag) is offered costs but no clue; choosing an option returns true and changes nothing" TO TL-CASE
     MOVE 0 TO MN-WSLOT-COUNT(WS-ROW, 1) MN-WSLOT-ITEM(WS-ROW, 1) MN-WSLOT-VAR(WS-ROW, 1)
     MOVE WS-SHOVEL TO MN-WSLOT-ITEM(WS-ROW, 1)
     MOVE 1 TO MN-WSLOT-COUNT(WS-ROW, 1)
     MOVE WS-LAPIS TO MN-WSLOT-ITEM(WS-ROW, 2)
     MOVE 3 TO MN-WSLOT-COUNT(WS-ROW, 2)
     MOVE 30 TO PL-XP-LEVEL(WS-ROW)
     CALL "MENU-STATION-UPDATE" USING WS-ROW
     MOVE MN-WDATA(WS-ROW, 3) TO WS-E1
     MOVE MN-WDATA(WS-ROW, 7) TO WS-E2
     CALL "MENU-STATION-BUTTON" USING WS-ROW PSB-BUTTON WS-RET
     MOVE WS-RET TO WS-E3
     MOVE PL-XP-LEVEL(WS-ROW) TO WS-E4
     MOVE MN-WSLOT-COUNT(WS-ROW, 2) TO WS-E5
     MOVE SPACES TO WS-TEXT
     STRING "cost3 " FUNCTION TRIM(WS-E1) " clue " FUNCTION TRIM(WS-E2) " ret " FUNCTION TRIM(WS-E3) " levels " FUNCTION TRIM(WS-E4)
         " lapis " FUNCTION TRIM(WS-E5) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "cost3 30 clue -1 ret 1 levels 30 lapis 3" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance itemcomp ench slot limit: carrying 2 swords onto slot 0 puts one in and keeps one on the cursor; a button id out of range returns false" TO TL-CASE
     MOVE 0 TO MN-WSLOT-COUNT(WS-ROW, 1) MN-WSLOT-ITEM(WS-ROW, 1) MN-WSLOT-VAR(WS-ROW, 1)
     MOVE WS-SWORD TO PL-CARRIED-ITEM(WS-ROW)
     MOVE 2 TO PL-CARRIED-COUNT(WS-ROW)
     MOVE 0 TO PL-CARRIED-VAR(WS-ROW)
     MOVE 0 TO WS-BUTTON WS-TYPE
     MOVE 0 TO WS-S
     CALL "TEST-CLICK-WIN" USING WS-CONN WS-S WS-BUTTON WS-TYPE
     MOVE MN-WSLOT-COUNT(WS-ROW, 1) TO WS-E1
     MOVE PL-CARRIED-COUNT(WS-ROW) TO WS-E2
     MOVE 7 TO PSB-BUTTON
     CALL "MENU-STATION-BUTTON" USING WS-ROW PSB-BUTTON WS-RET
     MOVE WS-RET TO WS-E3
     MOVE SPACES TO WS-TEXT
     STRING "slot " FUNCTION TRIM(WS-E1) " cursor " FUNCTION TRIM(WS-E2) " ret " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "slot 1 cursor 1 ret 0" TO TL-EXPECTED
     PERFORM CHECK
     MOVE "acceptance itemcomp ench swap: a hotbar swap of a stack of 2 swords into the item slot is refused (the slot takes one), a single sword goes in" TO TL-CASE
     MOVE 0 TO MN-WSLOT-COUNT(WS-ROW, 1) MN-WSLOT-ITEM(WS-ROW, 1) MN-WSLOT-VAR(WS-ROW, 1)
     MOVE 0 TO PL-CARRIED-COUNT(WS-ROW) PL-CARRIED-ITEM(WS-ROW)
     MOVE WS-SWORD TO PL-SLOT-ITEM(WS-ROW, 1)
     MOVE 2 TO PL-SLOT-COUNT(WS-ROW, 1)
     MOVE 0 TO WS-BUTTON
     MOVE 2 TO WS-TYPE
     MOVE 0 TO WS-S
     CALL "TEST-CLICK-WIN" USING WS-CONN WS-S WS-BUTTON WS-TYPE
     MOVE MN-WSLOT-COUNT(WS-ROW, 1) TO WS-E1
     MOVE PL-SLOT-COUNT(WS-ROW, 1) TO WS-E2
     MOVE 1 TO PL-SLOT-COUNT(WS-ROW, 1)
     CALL "TEST-CLICK-WIN" USING WS-CONN WS-S WS-BUTTON WS-TYPE
     MOVE MN-WSLOT-COUNT(WS-ROW, 1) TO WS-E3
     MOVE PL-SLOT-COUNT(WS-ROW, 1) TO WS-E4
     MOVE SPACES TO WS-TEXT
     STRING "refused " FUNCTION TRIM(WS-E1) "/" FUNCTION TRIM(WS-E2) " single " FUNCTION TRIM(WS-E3) "/" FUNCTION TRIM(WS-E4) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "refused 0/2 single 1/0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance itemcomp ench quick move out: a shift click of the item slot and of the lapis slot returns the stacks to the inventory" TO TL-CASE
     MOVE WS-LAPIS TO MN-WSLOT-ITEM(WS-ROW, 2)
     MOVE 5 TO MN-WSLOT-COUNT(WS-ROW, 2)
     MOVE 0 TO MN-WSLOT-VAR(WS-ROW, 2)
     MOVE 0 TO PL-SLOT-COUNT(WS-ROW, 1) PL-SLOT-ITEM(WS-ROW, 1)
     MOVE 1 TO WS-TYPE
     MOVE 0 TO WS-S
     CALL "TEST-CLICK-WIN" USING WS-CONN WS-S WS-BUTTON WS-TYPE
     MOVE 1 TO WS-S
     CALL "TEST-CLICK-WIN" USING WS-CONN WS-S WS-BUTTON WS-TYPE
     MOVE MN-WSLOT-COUNT(WS-ROW, 1) TO WS-E1
     MOVE MN-WSLOT-COUNT(WS-ROW, 2) TO WS-E2
     MOVE 0 TO WS-CNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
         IF PL-SLOT-ITEM(WS-ROW, WS-I) = WS-SWORD AND PL-SLOT-COUNT(WS-ROW, WS-I) > 0
             ADD PL-SLOT-COUNT(WS-ROW, WS-I) TO WS-CNT
         END-IF
         IF PL-SLOT-ITEM(WS-ROW, WS-I) = WS-LAPIS
             ADD 100 TO WS-CNT
             ADD PL-SLOT-COUNT(WS-ROW, WS-I) TO WS-CNT
         END-IF
     END-PERFORM
     MOVE WS-CNT TO WS-E3
     MOVE SPACES TO WS-TEXT
     STRING "slots " FUNCTION TRIM(WS-E1) "/" FUNCTION TRIM(WS-E2) " inventory " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "slots 0/0 inventory 106" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

*> Air above a floor of stone around the table and the ring of 32 bookshelves (dy 0 and 1).
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
     END-PERFORM
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 32
         CALL "ENCH-OFFSET" USING WS-J WS-DX WS-DY WS-DZ WS-TX WS-TY WS-TZ
         COMPUTE WS-X = WS-BX + WS-DX
         COMPUTE WS-Y = WS-BY + WS-DY
         COMPUTE WS-Z = WS-BZ + WS-DZ
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-SHELF
     END-PERFORM.

 USE-BLOCK.
     ADD 1 TO WS-SEQ
     CALL "TEST-USE-ON" USING WS-CONN WS-X WS-Y WS-Z WS-FACE WS-SEQ
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS.

 CHECK.
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-ITEMCOMP-ENCH.

 COPY CORETEST.
 COPY BETEST.
