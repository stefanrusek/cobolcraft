*> The grindstone as a live station menu (docs/protocol/40-menus-3 section 4; lane itemcomp3, T10604): station kind 2, MN-CFAMILY 22; own slots 0 and 1 the inputs (MN-WSLOT 1 and 2), own slot 2 the
*> result (MN-RESULT-*, MN-WRES 2); no data slots. A stack is item, count and patch handle (CSTACK.cpy).
*>   GRIND-HAS-ENCH USING handle, flag out        hasAnyEnchantments: enchantments (13) or stored_enchantments (45) is not empty, whatever the item
*>   GRIND-DAMAGEABLE USING item, handle, flag out   a max_damage and no unbreakable component
*>   GRIND-RESULT USING left item, count, handle, right item, count, handle, result item out, count out, handle out   computeResult (4.3); count 0 for no result
*>   GRIND-XP-TOTAL USING left item, handle, right item, handle, total out   the sum of the minimum costs of the enchantments that are not curses (4.4)
*>   MENU-GRIND-UPDATE USING row                  slotsChanged: the result follows the inputs
*>   MENU-GRIND-TAKEN USING row                   onTake (4.4): experience awarded at the block, both inputs emptied
*>   MENU-GRIND-QUICK USING row, menu slot, item out, count out   quickMoveStack (4.5)
*> The take sends Level Event 1042 (grindstone.use; 57-client-closures-2 section 3.2) to the players within 64 blocks of the block.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GRIND-HAS-ENCH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-T13                 BINARY-LONG VALUE 13.
 01 WS-T45                 BINARY-LONG VALUE 45.
 01 WS-N                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-HANDLE               BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-HANDLE L-FLAG.
     MOVE 0 TO L-FLAG
     CALL "SC-ENCH-COUNT" USING L-HANDLE WS-T13 WS-N
     IF WS-N > 0
         MOVE 1 TO L-FLAG
     END-IF
     CALL "SC-ENCH-COUNT" USING L-HANDLE WS-T45 WS-N
     IF WS-N > 0
         MOVE 1 TO L-FLAG
     END-IF
     GOBACK.
 END PROGRAM GRIND-HAS-ENCH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GRIND-DAMAGEABLE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-UTYPE               BINARY-LONG VALUE 4.
 01 WS-MAX                 BINARY-LONG.
 01 WS-VALUE               PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ITEM                 BINARY-LONG.
 01 L-HANDLE               BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ITEM L-HANDLE L-FLAG.
     MOVE 0 TO L-FLAG
     CALL "SP-GET-MAX-DAMAGE" USING L-ITEM L-HANDLE WS-MAX
     CALL "SP-GET-COMPONENT" USING L-HANDLE WS-UTYPE WS-VALUE WS-LENGTH WS-FOUND
     IF WS-MAX > 0 AND WS-FOUND = 0
         MOVE 1 TO L-FLAG
     END-IF
     GOBACK.
 END PROGRAM GRIND-DAMAGEABLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GRIND-ENCH-TYPE.
*> USING item, component type out: enchOf (4.3): stored_enchantments (45) for the enchanted book, enchantments (13) otherwise.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KEY                 PIC X(48).
 LINKAGE SECTION.
 01 L-ITEM                 BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ITEM L-TYPE.
     MOVE 13 TO L-TYPE
     CALL "TOOLUSE-KEY" USING L-ITEM WS-KEY
     IF WS-KEY = "enchanted_book"
         MOVE 45 TO L-TYPE
     END-IF
     GOBACK.
 END PROGRAM GRIND-ENCH-TYPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GRIND-STRIP.
*> USING item (in and out), handle (in and out): removeNonCurses (4.3): only the curses stay in enchOf; an enchanted book left with none becomes a book; the repair cost is 0 doubled and incremented once
*> for each curse that stays.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TYPE                BINARY-LONG.
 01 WS-RTYPE               BINARY-LONG VALUE 19.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-CURSE               BINARY-LONG.
 01 WS-KEEP.
    05 WS-KE OCCURS 24 TIMES.
       10 WS-KID           BINARY-LONG.
       10 WS-KLV           BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-LV                  BINARY-LONG.
 01 WS-BOOK                BINARY-LONG.
 01 WS-BECOMES             BINARY-LONG.
 01 WS-RC                  BINARY-LONG.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:book".
 01 WS-ROWTXT              PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-VALUE               PIC X(64).
 01 WS-POS                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ITEM                 BINARY-LONG.
 01 L-HANDLE               BINARY-LONG.
 PROCEDURE DIVISION USING L-ITEM L-HANDLE.
     CALL "GRIND-ENCH-TYPE" USING L-ITEM WS-TYPE
     CALL "SC-ENCH-COUNT" USING L-HANDLE WS-TYPE WS-N
     MOVE 0 TO WS-K
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N
         CALL "SC-ENCH-NTH" USING L-HANDLE WS-TYPE WS-I WS-ID WS-LV
         CALL "ENCH-IS-CURSE" USING WS-ID WS-CURSE
         IF WS-CURSE = 1 AND WS-K < 24
             ADD 1 TO WS-K
             MOVE WS-ID TO WS-KID(WS-K)
             MOVE WS-LV TO WS-KLV(WS-K)
         END-IF
     END-PERFORM
     CALL "SP-CLEAR-COMPONENT" USING L-HANDLE WS-TYPE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-K
         CALL "SC-ENCH-ADD" USING L-HANDLE WS-TYPE WS-KID(WS-I) WS-KLV(WS-I)
     END-PERFORM
     MOVE 0 TO WS-BOOK
     IF WS-TYPE = 45
         MOVE 1 TO WS-BOOK
     END-IF
     CALL "MN3-GRIND-REMOVE" USING WS-BOOK WS-K WS-BECOMES WS-RC
     IF WS-BECOMES = 1
         CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ROWTXT WS-STATUS
         MOVE WS-ITEM TO L-ITEM
     END-IF
     CALL "SP-CLEAR-COMPONENT" USING L-HANDLE WS-RTYPE
     IF WS-RC > 0
         MOVE SPACES TO WS-VALUE
         MOVE 1 TO WS-POS
         CALL "SP-VARINT-PUT" USING WS-VALUE WS-POS WS-RC
         SUBTRACT 1 FROM WS-POS
         CALL "SP-SET-COMPONENT" USING L-HANDLE WS-RTYPE WS-VALUE WS-POS
     END-IF
     GOBACK.
 END PROGRAM GRIND-STRIP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GRIND-RESULT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CITEMS.
 01 WS-AE                  BINARY-LONG.
 01 WS-BE                  BINARY-LONG.
 01 WS-SEN                 BINARY-LONG.
 01 WS-SAME                BINARY-LONG.
 01 WS-OUT                 BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-DAM                 BINARY-LONG.
 01 WS-MA                  BINARY-LONG.
 01 WS-MB                  BINARY-LONG.
 01 WS-DA                  BINARY-LONG.
 01 WS-DB                  BINARY-LONG.
 01 WS-MS                  BINARY-LONG.
 01 WS-MT                  BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-CNT                 BINARY-LONG.
 01 WS-MAXD                BINARY-LONG.
 01 WS-DMG                 BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-LV                  BINARY-LONG.
 01 WS-RL                  BINARY-LONG.
 01 WS-CURSE               BINARY-LONG.
 01 WS-APP                 BINARY-LONG.
 01 WS-NL                  BINARY-LONG.
 01 WS-MTYPE               BINARY-LONG VALUE 2.
 01 WS-VALUE               PIC X(64).
 01 WS-POS                 BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-HANDLE              BINARY-LONG.
 LINKAGE SECTION.
 01 L-AI                   BINARY-LONG.
 01 L-AC                   BINARY-LONG.
 01 L-AV                   BINARY-LONG.
 01 L-BI                   BINARY-LONG.
 01 L-BC                   BINARY-LONG.
 01 L-BV                   BINARY-LONG.
 01 L-OI                   BINARY-LONG.
 01 L-OC                   BINARY-LONG.
 01 L-OV                   BINARY-LONG.
 PROCEDURE DIVISION USING L-AI L-AC L-AV L-BI L-BC L-BV L-OI L-OC L-OV.
     GO TO MAIN-LINE.

*> mergeItems (4.3): the damage and count of the merge, the enchantments of the second added to the first, then removeNonCurses.
 MERGE-ITEMS.
     CALL "SP-GET-MAX-DAMAGE" USING L-AI L-AV WS-MA
     CALL "SP-GET-MAX-DAMAGE" USING L-BI L-BV WS-MB
     CALL "SP-GET-DAMAGE" USING L-AI L-AV WS-DA
     CALL "SP-GET-DAMAGE" USING L-BI L-BV WS-DB
     CALL "GRIND-DAMAGEABLE" USING L-AI L-AV WS-DAM
     MOVE IT-MAX-STACK(L-AI + 1) TO WS-MS
     MOVE 0 TO WS-MT
     IF L-AV = L-BV AND L-AC = L-BC
         MOVE 1 TO WS-MT
     END-IF
     CALL "MN3-GRIND-MERGE" USING WS-MA WS-DA WS-MB WS-DB WS-DAM WS-MS WS-MT WS-OK WS-CNT WS-MAXD WS-DMG
     IF WS-OK = 1
         MOVE L-AI TO L-OI
         MOVE L-AV TO L-OV
         MOVE WS-CNT TO L-OC
         IF WS-DAM = 1
             MOVE SPACES TO WS-VALUE
             MOVE 1 TO WS-POS
             CALL "SP-VARINT-PUT" USING WS-VALUE WS-POS WS-MAXD
             SUBTRACT 1 FROM WS-POS
             CALL "SP-SET-COMPONENT" USING L-OV WS-MTYPE WS-VALUE WS-POS
             CALL "SP-SET-DAMAGE" USING L-OV WS-DMG
         END-IF
         CALL "GRIND-ENCH-TYPE" USING L-BI WS-TYPE
         CALL "SC-ENCH-COUNT" USING L-BV WS-TYPE WS-N
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N
             CALL "SC-ENCH-NTH" USING L-BV WS-TYPE WS-I WS-ID WS-LV
             CALL "SC-ENCH-LEVEL" USING L-OV WS-TYPE WS-ID WS-RL
             CALL "ENCH-IS-CURSE" USING WS-ID WS-CURSE
             CALL "MN3-GRIND-MERGE-ENCH" USING WS-CURSE WS-RL WS-LV WS-APP WS-NL
             IF WS-APP = 1 AND WS-NL > 0
                 CALL "SC-ENCH-ADD" USING L-OV WS-TYPE WS-ID WS-NL
             END-IF
         END-PERFORM
         CALL "GRIND-STRIP" USING L-OI L-OV
     END-IF.

 MAIN-LINE.
     MOVE 0 TO L-OI L-OC L-OV
     MOVE 0 TO WS-AE WS-BE
     IF L-AC = 0
         MOVE 1 TO WS-AE
     END-IF
     IF L-BC = 0
         MOVE 1 TO WS-BE
     END-IF
     MOVE 0 TO WS-SEN WS-SAME
*>   The single item has enchantments (item-independent, 4.1); the two items are the same item.
     IF WS-AE = 0 AND WS-BE = 1
         CALL "GRIND-HAS-ENCH" USING L-AV WS-SEN
     END-IF
     IF WS-AE = 1 AND WS-BE = 0
         CALL "GRIND-HAS-ENCH" USING L-BV WS-SEN
     END-IF
     IF L-AI = L-BI
         MOVE 1 TO WS-SAME
     END-IF
     CALL "MN3-GRIND-COMPUTE" USING WS-AE WS-BE L-AC L-BC WS-SEN WS-SAME WS-OUT
     EVALUATE WS-OUT
         WHEN 1
             IF WS-AE = 0
                 MOVE L-AI TO L-OI
                 MOVE L-AV TO L-OV
             ELSE
                 MOVE L-BI TO L-OI
                 MOVE L-BV TO L-OV
             END-IF
             MOVE 1 TO L-OC
             CALL "GRIND-STRIP" USING L-OI L-OV
         WHEN 2
             PERFORM MERGE-ITEMS
     END-EVALUATE
     GOBACK.
 END PROGRAM GRIND-RESULT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GRIND-XP-TOTAL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-S                   BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-HANDLE              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-LV                  BINARY-LONG.
 01 WS-CURSE               BINARY-LONG.
 01 WS-MINB                BINARY-LONG.
 01 WS-MINP                BINARY-LONG.
 01 WS-MAXB                BINARY-LONG.
 01 WS-MAXP                BINARY-LONG.
 01 WS-PRIMARY             PIC X(112).
 01 WS-FOUND               BINARY-LONG.
 01 WS-COST                BINARY-LONG.
 LINKAGE SECTION.
 01 L-AI                   BINARY-LONG.
 01 L-AV                   BINARY-LONG.
 01 L-BI                   BINARY-LONG.
 01 L-BV                   BINARY-LONG.
 01 L-TOTAL                BINARY-LONG.
 PROCEDURE DIVISION USING L-AI L-AV L-BI L-BV L-TOTAL.
     MOVE 0 TO L-TOTAL
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 2
         IF WS-S = 1
             MOVE L-AI TO WS-ITEM
             MOVE L-AV TO WS-HANDLE
         ELSE
             MOVE L-BI TO WS-ITEM
             MOVE L-BV TO WS-HANDLE
         END-IF
         IF WS-ITEM > 0
             CALL "GRIND-ENCH-TYPE" USING WS-ITEM WS-TYPE
             CALL "SC-ENCH-COUNT" USING WS-HANDLE WS-TYPE WS-N
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N
                 CALL "SC-ENCH-NTH" USING WS-HANDLE WS-TYPE WS-I WS-ID WS-LV
                 CALL "ENCH-IS-CURSE" USING WS-ID WS-CURSE
                 IF WS-CURSE = 0
                     CALL "ENCH-COST-DEF" USING WS-ID WS-MINB WS-MINP WS-MAXB WS-MAXP WS-PRIMARY WS-FOUND
                     CALL "MN3-GRIND-MINCOST" USING WS-MINB WS-MINP WS-LV WS-COST
                     ADD WS-COST TO L-TOTAL
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM GRIND-XP-TOTAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-GRIND-UPDATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CMENU.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-VAR                 BINARY-LONG.
 01 WS-BI                  BINARY-LONG.
 01 WS-BC                  BINARY-LONG.
 01 WS-BV                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE MN-WSLOT-ITEM(L-ROW, 2) TO WS-BI
     MOVE MN-WSLOT-COUNT(L-ROW, 2) TO WS-BC
     MOVE MN-WSLOT-VAR(L-ROW, 2) TO WS-BV
     CALL "GRIND-RESULT" USING MN-WSLOT-ITEM(L-ROW, 1) MN-WSLOT-COUNT(L-ROW, 1) MN-WSLOT-VAR(L-ROW, 1)
         WS-BI WS-BC WS-BV WS-ITEM WS-COUNT WS-VAR
     MOVE WS-ITEM TO MN-RESULT-ITEM(L-ROW)
     MOVE WS-COUNT TO MN-RESULT-COUNT(L-ROW)
     MOVE WS-VAR TO MN-RESULT-VAR(L-ROW)
     GOBACK.
 END PROGRAM MENU-GRIND-UPDATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-GRIND-TAKEN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CMENU.
 01 WS-T                   BINARY-LONG.
 01 WS-AI                  BINARY-LONG.
 01 WS-AV                  BINARY-LONG.
 01 WS-BI                  BINARY-LONG.
 01 WS-BV                  BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-XP                  BINARY-LONG.
 01 WS-DRAWS               BINARY-LONG.
 01 WS-SALT                BINARY-LONG VALUE 3.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-EVENT               BINARY-LONG VALUE 1042.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-NONE2               BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "LEVEL-EVENT" USING MN-BENCH-DIM(L-ROW) WS-EVENT MN-BENCH-X(L-ROW) MN-BENCH-Y(L-ROW) MN-BENCH-Z(L-ROW)
         WS-NONE WS-NONE2
     MOVE MN-WSLOT-ITEM(L-ROW, 1) TO WS-AI
     MOVE MN-WSLOT-VAR(L-ROW, 1) TO WS-AV
     MOVE MN-WSLOT-ITEM(L-ROW, 2) TO WS-BI
     MOVE MN-WSLOT-VAR(L-ROW, 2) TO WS-BV
     CALL "GRIND-XP-TOTAL" USING WS-AI WS-AV WS-BI WS-BV WS-T
     MOVE 0 TO WS-DRAW
     IF WS-T > 0
         COMPUTE WS-H = (WS-T + 1) / 2
         CALL "XP-RANDOM" USING WS-SALT WS-H WS-DRAW
     END-IF
     CALL "MN3-GRIND-XP" USING WS-T WS-DRAW WS-H WS-XP WS-DRAWS
     IF WS-XP > 0
         COMPUTE WS-X = MN-BENCH-X(L-ROW) + 0.5
         COMPUTE WS-Y = MN-BENCH-Y(L-ROW) + 0.5
         COMPUTE WS-Z = MN-BENCH-Z(L-ROW) + 0.5
         CALL "XP-AWARD" USING MN-BENCH-DIM(L-ROW) WS-X WS-Y WS-Z WS-XP
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 2
         MOVE 0 TO MN-WSLOT-ITEM(L-ROW, WS-I) MN-WSLOT-COUNT(L-ROW, WS-I) MN-WSLOT-VAR(L-ROW, WS-I)
     END-PERFORM
     CALL "MENU-STATION-UPDATE" USING L-ROW
     GOBACK.
 END PROGRAM MENU-GRIND-TAKEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-GRIND-QUICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CMENU.
 01 WS-CAN                 BINARY-LONG.
 01 WS-R                   BINARY-LONG VALUE 2.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-RET-ITEM             BINARY-LONG.
 01 L-RET-COUNT            BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-RET-ITEM L-RET-COUNT.
     MOVE 0 TO WS-CAN
     IF MN-WSLOT-COUNT(L-ROW, 1) = 0 OR MN-WSLOT-COUNT(L-ROW, 2) = 0
         MOVE 1 TO WS-CAN
     END-IF
     CALL "MENU-STATION-COMBINER-QUICK" USING L-ROW L-SLOT WS-R WS-CAN L-RET-ITEM L-RET-COUNT
     GOBACK.
 END PROGRAM MENU-GRIND-QUICK.
