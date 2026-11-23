*> The enchanting table as a live station menu (docs/protocol/40-menus-4 section 2, 17 section 6.5; lane itemcomp3, T10601): station kind 7, MN-CFAMILY 27; own slot 0 the item (a stack of one),
*> own slot 1 the lapis lazuli (MN-WSLOT 1 and 2); no result slot. The ten data slots are MN-WDATA 1 to 10: the three costs, the menu's enchantment seed (the whole int; the wire carries its low 16
*> bits, MENU-STATION-SYNC), the three clue enchantments and the three clue levels (-1 for none). The player's seed is PL-ENCH-SEED (drawn at the first opening, renewed after every enchant).
*>   MENU-ENCH-OPEN USING row                  the constructor: the seed of the player into data slot 3, the clues -1
*>   MENU-ENCH-UPDATE USING row                slotsChanged (2.4): costs and clues follow the item, the lapis does not matter, the bookshelves and the menu seed do
*>   MENU-ENCH-BUTTON USING row, button id, returned out   clickMenuButton (2.6)
*>   MENU-ENCH-QUICK USING row, menu slot, item out, count out   quickMoveStack (2.7)
*>   MENU-SLOT-MAX USING row, menu slot, item, maximum out   the stack size a slot takes: 1 for the enchanted item's slot, else the item's stack size
*> Gaps: the enchant_item statistic and trigger, the table's sound and the player's seed on disk are not done.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-ENCH-OPEN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CMENU.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     IF PL-ENCH-INIT(L-ROW) = 0
         CALL "ENCH-SEED-RENEW" USING L-ROW
     END-IF
     MOVE PL-ENCH-SEED(L-ROW) TO MN-WDATA(L-ROW, 4)
     PERFORM VARYING WS-I FROM 5 BY 1 UNTIL WS-I > 10
         MOVE -1 TO MN-WDATA(L-ROW, WS-I)
     END-PERFORM
     GOBACK.
 END PROGRAM MENU-ENCH-OPEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENCH-SEED-RENEW.
*> USING row: the player's seed becomes a fresh int (a hash of the old seed, the tick and the row, standing in for nextInt of the player's own random).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-VALUES.
    05 WS-V                BINARY-DOUBLE OCCURS 16 TIMES.
 01 WS-COUNT               BINARY-LONG VALUE 3.
 01 WS-H                   BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     COMPUTE WS-V(1) = FUNCTION MOD(PL-ENCH-SEED(L-ROW), 4294967296)
     MOVE CW-TICKS TO WS-V(2)
     MOVE L-ROW TO WS-V(3)
     CALL "RNG-HASH" USING WS-COUNT WS-VALUES WS-H
     IF WS-H >= 2147483648
         SUBTRACT 4294967296 FROM WS-H
     END-IF
     MOVE WS-H TO PL-ENCH-SEED(L-ROW)
     MOVE 1 TO PL-ENCH-INIT(L-ROW)
     GOBACK.
 END PROGRAM ENCH-SEED-RENEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-ENCH-UPDATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CMENU.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-SHELVES             BINARY-LONG.
 01 WS-FLAG                BINARY-LONG VALUE 1.
 01 WS-C0                  BINARY-LONG.
 01 WS-C1                  BINARY-LONG.
 01 WS-C2                  BINARY-LONG.
 01 WS-COST                BINARY-LONG.
 01 WS-SEED                BINARY-LONG.
 01 WS-ST                  BINARY-DOUBLE UNSIGNED.
 01 WS-COUNT               BINARY-LONG.
 01 WS-LIST.
    05 WS-E OCCURS 16 TIMES.
       10 WS-EID           BINARY-LONG.
       10 WS-ELV           BINARY-LONG.
 01 WS-CLUE                BINARY-LONG.
 01 WS-NONE                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         MOVE 0 TO MN-WDATA(L-ROW, WS-I)
         MOVE -1 TO MN-WDATA(L-ROW, WS-I + 4) MN-WDATA(L-ROW, WS-I + 7)
     END-PERFORM
     MOVE 0 TO WS-OK
     IF MN-WSLOT-COUNT(L-ROW, 1) > 0
         CALL "ENCH-ENCHANTABILITY" USING MN-WSLOT-ITEM(L-ROW, 1) MN-WSLOT-VAR(L-ROW, 1) WS-N WS-OK
     END-IF
     IF WS-OK = 0
         GOBACK
     END-IF
     CALL "ENCH-SHELVES" USING MN-BENCH-DIM(L-ROW) MN-BENCH-X(L-ROW) MN-BENCH-Y(L-ROW) MN-BENCH-Z(L-ROW) WS-SHELVES
     MOVE MN-WDATA(L-ROW, 4) TO WS-SEED
     CALL "ENCH-COSTS" USING WS-SEED WS-SHELVES WS-FLAG WS-C0 WS-C1 WS-C2
     MOVE WS-C0 TO MN-WDATA(L-ROW, 1)
     MOVE WS-C1 TO MN-WDATA(L-ROW, 2)
     MOVE WS-C2 TO MN-WDATA(L-ROW, 3)
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 2
         MOVE MN-WDATA(L-ROW, WS-I + 1) TO WS-COST
         IF WS-COST > 0
             CALL "ENCH-OFFER" USING WS-SEED WS-I MN-WSLOT-ITEM(L-ROW, 1) WS-N WS-COST WS-ST WS-COUNT WS-LIST
             IF WS-COUNT > 0
                 CALL "ENCH-CLUE-DRAW" USING WS-ST WS-COUNT WS-CLUE
                 MOVE WS-EID(WS-CLUE + 1) TO MN-WDATA(L-ROW, WS-I + 5)
                 MOVE WS-ELV(WS-CLUE + 1) TO MN-WDATA(L-ROW, WS-I + 8)
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM MENU-ENCH-UPDATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-ENCH-BUTTON.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CMENU.
 01 WS-N                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-INF                 BINARY-LONG.
 01 WS-COST                BINARY-LONG.
 01 WS-EMPTY               BINARY-LONG.
 01 WS-NEED                BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-LAPIS               BINARY-LONG.
 01 WS-LEMPTY              BINARY-LONG.
 01 WS-BOOK                BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-NLEVEL              BINARY-LONG.
 01 WS-NLAPIS              BINARY-LONG.
 01 WS-TRANS               BINARY-LONG.
 01 WS-RENEW               BINARY-LONG.
 01 WS-EMPTIED             BINARY-LONG.
 01 WS-SEED                BINARY-LONG.
 01 WS-ST                  BINARY-DOUBLE UNSIGNED.
 01 WS-COUNT               BINARY-LONG.
 01 WS-LIST.
    05 WS-E OCCURS 16 TIMES.
       10 WS-EID           BINARY-LONG.
       10 WS-ELV           BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:enchanted_book".
 01 WS-ROWTXT              PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 01 L-RETURNED             BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ID L-RETURNED.
     MOVE 0 TO L-RETURNED
     MOVE 0 TO WS-INF WS-EMPTY
     IF PL-MODE(L-ROW) = 1
         MOVE 1 TO WS-INF
     END-IF
     IF MN-WSLOT-COUNT(L-ROW, 1) = 0
         MOVE 1 TO WS-EMPTY
     END-IF
     MOVE 0 TO WS-COST
     IF L-ID >= 0 AND L-ID < 3
         MOVE MN-WDATA(L-ROW, L-ID + 1) TO WS-COST
     END-IF
     CALL "ENCH-BUTTON" USING L-ID MN-WSLOT-COUNT(L-ROW, 2) PL-XP-LEVEL(L-ROW) WS-INF WS-COST WS-EMPTY L-RETURNED WS-NEED
     IF L-RETURNED = 0
         GOBACK
     END-IF
     CALL "ENCH-ENCHANTABILITY" USING MN-WSLOT-ITEM(L-ROW, 1) MN-WSLOT-VAR(L-ROW, 1) WS-N WS-OK
     MOVE MN-WDATA(L-ROW, 4) TO WS-SEED
     CALL "ENCH-OFFER" USING WS-SEED L-ID MN-WSLOT-ITEM(L-ROW, 1) WS-N WS-COST WS-ST WS-COUNT WS-LIST
     MOVE 0 TO WS-LEMPTY WS-BOOK
     IF WS-COUNT = 0
         MOVE 1 TO WS-LEMPTY
     END-IF
     CALL "ENCH-IS-BOOK" USING MN-WSLOT-ITEM(L-ROW, 1) WS-BOOK
     MOVE MN-WSLOT-COUNT(L-ROW, 2) TO WS-LAPIS
     CALL "ENCH-EFFECT" USING PL-XP-LEVEL(L-ROW) WS-NEED WS-INF WS-LAPIS WS-LEMPTY WS-BOOK WS-DONE WS-NLEVEL WS-NLAPIS
         WS-TRANS WS-RENEW WS-EMPTIED
     IF WS-DONE = 0
         GOBACK
     END-IF
     CALL "XP-TAKE-LEVELS" USING L-ROW WS-NEED
     CALL "ENCH-SEED-RENEW" USING L-ROW
*>   A book becomes an enchanted book (same count and components) and holds stored_enchantments, every other item enchantments (13).
     MOVE 13 TO WS-TYPE
     IF WS-TRANS = 1
         CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ROWTXT WS-STATUS
         MOVE WS-ITEM TO MN-WSLOT-ITEM(L-ROW, 1)
         MOVE 45 TO WS-TYPE
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
         CALL "SC-ENCH-ADD" USING MN-WSLOT-VAR(L-ROW, 1) WS-TYPE WS-EID(WS-I) WS-ELV(WS-I)
     END-PERFORM
     MOVE WS-NLAPIS TO MN-WSLOT-COUNT(L-ROW, 2)
     IF WS-EMPTIED = 1
         MOVE 0 TO MN-WSLOT-ITEM(L-ROW, 2) MN-WSLOT-VAR(L-ROW, 2)
     END-IF
     MOVE PL-ENCH-SEED(L-ROW) TO MN-WDATA(L-ROW, 4)
     CALL "MENU-STATION-UPDATE" USING L-ROW
     GOBACK.
 END PROGRAM MENU-ENCH-BUTTON.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENCH-IS-BOOK.
*> USING item, flag out: the item is the plain book (the table's list of a book loses an entry; an enchanted book is made of it).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CITEMS.
 LINKAGE SECTION.
 01 L-ITEM                 BINARY-LONG.
 01 L-BOOK                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ITEM L-BOOK.
     MOVE 0 TO L-BOOK
     IF L-ITEM > 0 AND L-ITEM < IT-COUNT
         IF IT-KEY(L-ITEM + 1) = "minecraft:book" OR IT-KEY(L-ITEM + 1) = "book"
             MOVE 1 TO L-BOOK
         END-IF
     END-IF
     GOBACK.
 END PROGRAM ENCH-IS-BOOK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-ENCH-QUICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CMENU.
 COPY CITEMS.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-VAR                 BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 01 WS-MOVED               BINARY-LONG.
 01 WS-LAPIS               BINARY-LONG.
 01 WS-E0                  BINARY-LONG.
 01 WS-RULE                BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-END                 BINARY-LONG.
 01 WS-REV                 BINARY-LONG.
 01 WS-SINGLE              BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-SLOT0               BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-RET-ITEM             BINARY-LONG.
 01 L-RET-COUNT            BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-RET-ITEM L-RET-COUNT.
     MOVE 0 TO L-RET-ITEM L-RET-COUNT
     CALL "MENU-GET-X" USING L-ROW L-SLOT WS-ITEM WS-COUNT WS-VAR
     IF WS-COUNT = 0
         GOBACK
     END-IF
     CALL "ENCH-IS-LAPIS" USING WS-ITEM WS-LAPIS
     MOVE 0 TO WS-E0
     IF MN-WSLOT-COUNT(L-ROW, 1) = 0
         MOVE 1 TO WS-E0
     END-IF
     CALL "ENCH-QUICK" USING L-SLOT WS-LAPIS WS-E0 WS-RULE WS-FIRST WS-END WS-REV WS-SINGLE
     MOVE WS-COUNT TO WS-LEFT
     MOVE 0 TO WS-MOVED
     EVALUATE WS-RULE
         WHEN 1
             CALL "MENU-MOVE-TO-X" USING L-ROW WS-ITEM WS-LEFT WS-FIRST WS-END WS-REV WS-MOVED WS-VAR
         WHEN 2
             CALL "MENU-MOVE-TO-X" USING L-ROW WS-ITEM WS-LEFT WS-FIRST WS-END WS-REV WS-MOVED WS-VAR
         WHEN 3
             CALL "MENU-SET-X" USING L-ROW WS-SLOT0 WS-ITEM WS-ONE WS-VAR
             SUBTRACT 1 FROM WS-LEFT
             MOVE 1 TO WS-MOVED
     END-EVALUATE
     CALL "MENU-QUICK-FINISH" USING L-ROW L-SLOT WS-ITEM WS-COUNT WS-LEFT WS-MOVED L-RET-ITEM L-RET-COUNT
     GOBACK.
 END PROGRAM MENU-ENCH-QUICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENCH-IS-LAPIS.
*> USING item, flag out: the item is lapis lazuli.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CITEMS.
 LINKAGE SECTION.
 01 L-ITEM                 BINARY-LONG.
 01 L-LAPIS                BINARY-LONG.
 PROCEDURE DIVISION USING L-ITEM L-LAPIS.
     MOVE 0 TO L-LAPIS
     IF L-ITEM > 0 AND L-ITEM < IT-COUNT
         IF IT-KEY(L-ITEM + 1) = "minecraft:lapis_lazuli" OR IT-KEY(L-ITEM + 1) = "lapis_lazuli"
             MOVE 1 TO L-LAPIS
         END-IF
     END-IF
     GOBACK.
 END PROGRAM ENCH-IS-LAPIS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-SLOT-MAX.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CMENU.
 COPY CITEMS.
 01 WS-KIND                BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-ITEM L-MAX.
     MOVE 64 TO L-MAX
     IF L-ITEM > 0 AND L-ITEM < IT-COUNT
         MOVE IT-MAX-STACK(L-ITEM + 1) TO L-MAX
     END-IF
*>   The enchanting table's item slot takes one item whatever the item's stack size (40-4 section 2.2).
     IF MN-WINDOW(L-ROW) > 0 AND MN-CFAMILY(L-ROW) = 27 AND L-SLOT = 0
         MOVE 1 TO L-MAX
     END-IF
*>   The mount screen's saddle and body slots take one item (40-6 section 2.3: ArmorSlot, max stack 1).
     IF MN-WINDOW(L-ROW) > 0 AND MN-CFAMILY(L-ROW) = 15 AND L-SLOT < 2
         MOVE 1 TO L-MAX
     END-IF
*>   The brewing stand's bottle slots take one item each (40-2 section 4.3).
     IF MN-WINDOW(L-ROW) > 0 AND MN-CFAMILY(L-ROW) = 9 AND L-SLOT < 3
         MOVE 1 TO L-MAX
     END-IF
     GOBACK.
 END PROGRAM MENU-SLOT-MAX.
