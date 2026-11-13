*> The workstation menus in the live window of a player (docs/protocol/40-menus-1-model-and-containers.md, 40-menus-3 and 40-menus-4; 002-lane-stations,
*> T5200 and on): stonecutter, grindstone, smithing table, anvil, loom, cartography table, enchanting table and brewing stand. A workstation menu is a
*> container menu (MN-CSIZE > 0) whose own slots are kept in the player's menu row (MN-WSLOT, the result slot in MN-RESULT-*): MN-CFAMILY is 20 + the
*> station kind below, MN-WRES the own slot that is the result slot (MENU-LOCATE names it as the result slot, kind 4, so the take rules of the result
*> slot are the bench's: the whole stack leaves, MENU-RESULT-TAKEN is called, nothing may be placed). The pure rules of the documents are the MN2- to MN4-
*> and ENCH- programs of menu-40-2.cob to menu-enchanting.cob; this file reads the live state, calls them and applies what they decide.
*>
*> Station kinds: 1 stonecutter, 2 grindstone, 3 smithing table, 4 anvil, 5 loom, 6 cartography table, 7 enchanting table, 8 brewing stand.
*>
*> Opening (Use Item On on the block, BLOCK-USE-ON, not sneaking with an item held): the menu already open is closed first, the container id is the next
*> of the cycle, Open Screen carries the menu type and the translatable title (container.stonecutter ...), Container Set Content and the data slots follow.
*> The menu is checked every tick (MENU-STILL-VALID -> MENU-CONT-VALID): the block must still be the station. Closing returns the carried stack and the
*> input slots to the player (what does not fit is thrown, MENU-STATION-STOP); the result slot is never returned.
*>
*> Entry points:
*>   MENU-STATION-KIND USING block state, kind out                  0 when the block is no workstation
*>   MENU-STATION-INFO USING kind, menu type out, own slots out, result slot out (-1 none), title key out (PIC X(48))
*>   MENU-STATION-OPEN USING connection id, x, y, z, kind
*>   MENU-STATION-GET / -SET USING row, own slot, item (out), count (out), patch handle (out)   the own slots other than the result slot
*>   MENU-STATION-MAYPLACE USING row, own slot, item, result out
*>   MENU-STATION-UPDATE USING row                                  slotsChanged: the result and the list follow the input slots
*>   MENU-STATION-TAKEN USING row                                   the result slot was emptied by a take: the inputs are used up
*>   MENU-STATION-QUICK USING row, menu slot, item out, count out   quickMoveStack
*>   MENU-STATION-STOP USING row                                    the close: inputs back to the player
*>   MENU-STATION-SYNC USING row                                    Container Set Data for every data slot that changed
*>   STATION-BUTTON USING connection id, PLAY-SERVERBOUND           Container Button Click (05c 0x11)
*>   MENU-STONE-COUNT USING item, size out / MENU-STONE-NTH USING item, index, result item out, result count out   the stonecutter list of an input item

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-STATION-KIND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-KEY                 PIC X(48).
 01 WS-BARE                PIC X(48).
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-KIND.
     MOVE 0 TO L-KIND
     IF L-STATE < 0 OR L-STATE >= CB-STATE-COUNT
         GOBACK
     END-IF
     MOVE CB-KEY(CB-S-BLOCK(L-STATE + 1) + 1) TO WS-KEY
     CALL "KEY-BARE" USING WS-KEY WS-BARE
     EVALUATE WS-BARE
         WHEN "stonecutter"
             MOVE 1 TO L-KIND
         WHEN "grindstone"
             MOVE 2 TO L-KIND
         WHEN "smithing_table"
             MOVE 3 TO L-KIND
         WHEN "anvil"
         WHEN "chipped_anvil"
         WHEN "damaged_anvil"
             MOVE 4 TO L-KIND
         WHEN "loom"
             MOVE 5 TO L-KIND
         WHEN "cartography_table"
             MOVE 6 TO L-KIND
         WHEN "enchanting_table"
             MOVE 7 TO L-KIND
         WHEN "brewing_stand"
             MOVE 8 TO L-KIND
     END-EVALUATE
     GOBACK.
 END PROGRAM MENU-STATION-KIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-STATION-INFO.
*> The identity tables of 40-3 section 8.1 and 40-4 section 1 (MN3-IDENT, MN4-IDENT, MN3-TITLE, MN4-TITLE) and of 40-2 (brewing stand: type 11).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OWN                 BINARY-LONG.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-DATA                BINARY-LONG.
 01 WS-SHIFT               BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-T1                  PIC X(96).
 01 WS-T2                  PIC X(96).
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-OWN                  BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 01 L-TITLE                PIC X(48).
 PROCEDURE DIVISION USING L-KIND L-TYPE L-OWN L-RESULT L-TITLE.
     MOVE SPACES TO L-TITLE
     MOVE -1 TO L-RESULT
     EVALUATE L-KIND
         WHEN 1
             MOVE 4 TO WS-K
             CALL "MN4-IDENT" USING WS-K L-TYPE L-OWN WS-TOTAL WS-DATA WS-SHIFT
             CALL "MN4-TITLE" USING WS-K WS-T1 WS-T2
             MOVE 1 TO L-RESULT
         WHEN 2
             MOVE 2 TO WS-K
             CALL "MN3-IDENT" USING WS-K L-TYPE L-OWN WS-TOTAL WS-DATA
             CALL "MN3-TITLE" USING WS-K WS-T1 WS-T2
             MOVE 2 TO L-RESULT
         WHEN 3
             MOVE 3 TO WS-K
             CALL "MN3-IDENT" USING WS-K L-TYPE L-OWN WS-TOTAL WS-DATA
             CALL "MN3-TITLE" USING WS-K WS-T1 WS-T2
             MOVE 3 TO L-RESULT
         WHEN 4
             MOVE 1 TO WS-K
             CALL "MN3-IDENT" USING WS-K L-TYPE L-OWN WS-TOTAL WS-DATA
             CALL "MN3-TITLE" USING WS-K WS-T1 WS-T2
             MOVE 2 TO L-RESULT
         WHEN 5
             MOVE 2 TO WS-K
             CALL "MN4-IDENT" USING WS-K L-TYPE L-OWN WS-TOTAL WS-DATA WS-SHIFT
             CALL "MN4-TITLE" USING WS-K WS-T1 WS-T2
             MOVE 3 TO L-RESULT
         WHEN 6
             MOVE 3 TO WS-K
             CALL "MN4-IDENT" USING WS-K L-TYPE L-OWN WS-TOTAL WS-DATA WS-SHIFT
             CALL "MN4-TITLE" USING WS-K WS-T1 WS-T2
             MOVE 2 TO L-RESULT
         WHEN 7
             MOVE 1 TO WS-K
             CALL "MN4-IDENT" USING WS-K L-TYPE L-OWN WS-TOTAL WS-DATA WS-SHIFT
             CALL "MN4-TITLE" USING WS-K WS-T1 WS-T2
         WHEN OTHER
             MOVE 11 TO L-TYPE
             MOVE 5 TO L-OWN
             MOVE "container.brewing" TO WS-T1
     END-EVALUATE
     MOVE WS-T1 TO L-TITLE
     GOBACK.
 END PROGRAM MENU-STATION-INFO.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-STONE-COUNT.
*> USING input item, size out: the number of stonecutting recipes (serializer 18 of the recipe store, in store order) whose ingredient takes the item;
*> 0 for an empty input (selectByInput of 40-4 section 4.4).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTRECIPE.
 01 WS-K                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ITEM                 BINARY-LONG.
 01 L-SIZE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ITEM L-SIZE.
     MOVE 0 TO L-SIZE
     IF L-ITEM <= 0
         GOBACK
     END-IF
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > RC-COUNT
         IF RR-SERIALIZER(WS-K) = 18
             CALL "CRAFT-ING-TEST" USING L-ITEM RR-ING(WS-K, 1) WS-OK
             IF WS-OK = 1
                 ADD 1 TO L-SIZE
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM MENU-STONE-COUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-STONE-NTH.
*> USING input item, index (0-based), result item out, result count out: the result of the index-th entry of the list of the item (0 and 0 when the
*> index is outside the list or the result item is unknown).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTRECIPE.
 COPY CONTENT.
 01 WS-K                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ROW                 PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ITEM                 BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-ITEM L-INDEX L-RESULT L-COUNT.
     MOVE 0 TO L-RESULT L-COUNT
     IF L-ITEM <= 0 OR L-INDEX < 0
         GOBACK
     END-IF
     MOVE 0 TO WS-N
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > RC-COUNT OR WS-N > L-INDEX
         IF RR-SERIALIZER(WS-K) = 18
             CALL "CRAFT-ING-TEST" USING L-ITEM RR-ING(WS-K, 1) WS-OK
             IF WS-OK = 1
                 IF WS-N = L-INDEX
                     MOVE RR-RESULT-ID(WS-K) TO WS-KEY
                     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY L-RESULT WS-ROW WS-STATUS
                     IF WS-STATUS = CT-OK
                         MOVE RR-RESULT-COUNT(WS-K) TO L-COUNT
                     ELSE
                         MOVE 0 TO L-RESULT
                     END-IF
                 END-IF
                 ADD 1 TO WS-N
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM MENU-STONE-NTH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-STATION-OPEN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CMENU.
 COPY PROTO.
 01 WS-READY               PIC 9 VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 8192.
 01 WS-PACKET-ID           BINARY-LONG VALUE 60.
 01 WS-ROW                 BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-OWN                 BINARY-LONG.
 01 WS-RES                 BINARY-LONG.
 01 WS-TITLE               PIC X(48).
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-X L-Y L-Z L-KIND.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     MOVE CN-PLAYER(L-ID) TO WS-ROW
     CALL "MENU-STATION-INFO" USING L-KIND WS-TYPE WS-OWN WS-RES WS-TITLE
     IF MN-WINDOW(WS-ROW) > 0 OR PL-CARRIED-COUNT(WS-ROW) > 0
         CALL "MENU-CLOSE" USING L-ID
     END-IF
     COMPUTE MN-COUNTER(WS-ROW) = FUNCTION MOD(MN-COUNTER(WS-ROW), 100) + 1
     MOVE MN-COUNTER(WS-ROW) TO MN-WINDOW(WS-ROW)
     MOVE WS-TYPE TO MN-TYPE(WS-ROW)
     MOVE 1 TO MN-STATE-ID(WS-ROW)
     MOVE PL-DIM(WS-ROW) TO MN-BENCH-DIM(WS-ROW)
     MOVE L-X TO MN-BENCH-X(WS-ROW)
     MOVE L-Y TO MN-BENCH-Y(WS-ROW)
     MOVE L-Z TO MN-BENCH-Z(WS-ROW)
     MOVE WS-OWN TO MN-CSIZE(WS-ROW)
     COMPUTE MN-CFAMILY(WS-ROW) = 20 + L-KIND
     MOVE 0 TO MN-CBE1(WS-ROW) MN-CBE2(WS-ROW) MN-COPEN(WS-ROW, 1) MN-COPEN(WS-ROW, 2)
     MOVE WS-RES TO MN-WRES(WS-ROW)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         MOVE 0 TO MN-WSLOT-ITEM(WS-ROW, WS-I) MN-WSLOT-COUNT(WS-ROW, WS-I) MN-WSLOT-VAR(WS-ROW, WS-I)
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
         MOVE 0 TO MN-WDATA(WS-ROW, WS-I) MN-WSENT(WS-ROW, WS-I)
     END-PERFORM
     MOVE -1 TO MN-WSEL(WS-ROW)
     MOVE 0 TO MN-WKEEP(WS-ROW) MN-WSOUND(WS-ROW)
     MOVE -1 TO MN-WLIST(WS-ROW)
     MOVE 0 TO MN-RESULT-ITEM(WS-ROW) MN-RESULT-COUNT(WS-ROW) MN-RESULT-VAR(WS-ROW)
     INITIALIZE PB-TEXT
     MOVE PB-TEXT-TRANSLATE TO PB-TX-KIND
     MOVE WS-TITLE TO PB-TX-VALUE
     COMPUTE PB-TX-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(WS-TITLE TRAILING))
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-OPEN-SCREEN" USING PB-BUFFER MN-WINDOW(WS-ROW) WS-TYPE PB-TEXT
     CALL "CORE-SEND" USING L-ID PB-BUFFER
     CALL "MENU-STATION-UPDATE" USING WS-ROW
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PLAY-CONTENT-BUILD" USING WS-ROW PB-BUFFER
     CALL "CORE-SEND" USING L-ID PB-BUFFER
     CALL "MENU-STATION-SYNC" USING WS-ROW
     GOBACK.
 END PROGRAM MENU-STATION-OPEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-STATION-GET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CMENU.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-VAR                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-ITEM L-COUNT L-VAR.
     MOVE MN-WSLOT-ITEM(L-ROW, L-SLOT + 1) TO L-ITEM
     MOVE MN-WSLOT-COUNT(L-ROW, L-SLOT + 1) TO L-COUNT
     MOVE MN-WSLOT-VAR(L-ROW, L-SLOT + 1) TO L-VAR
     GOBACK.
 END PROGRAM MENU-STATION-GET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-STATION-SET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CMENU.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-VAR                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-ITEM L-COUNT L-VAR.
     MOVE L-ITEM TO MN-WSLOT-ITEM(L-ROW, L-SLOT + 1)
     MOVE L-COUNT TO MN-WSLOT-COUNT(L-ROW, L-SLOT + 1)
     MOVE L-VAR TO MN-WSLOT-VAR(L-ROW, L-SLOT + 1)
     GOBACK.
 END PROGRAM MENU-STATION-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-STATION-MAYPLACE.
*> USING row, own slot, item, result out: the stonecutter's input slot takes any item (40-4 section 4.2); the other stations' rules follow with each station.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-ITEM L-RESULT.
     MOVE 1 TO L-RESULT
     GOBACK.
 END PROGRAM MENU-STATION-MAYPLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-STONE-SETUP.
*> USING row, index: setupResultSlot of 40-4 section 4.4: the result slot takes the result of the index-th entry of the list of the input, or is cleared.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CMENU.
 01 WS-SIZE                BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-INDEX.
     MOVE 0 TO WS-ITEM WS-COUNT
     IF MN-WSLOT-COUNT(L-ROW, 1) > 0
         CALL "MENU-STONE-COUNT" USING MN-WSLOT-ITEM(L-ROW, 1) WS-SIZE
         CALL "MN4-STONE-RESULT" USING WS-SIZE L-INDEX WS-OK
         IF WS-OK = 1
             CALL "MENU-STONE-NTH" USING MN-WSLOT-ITEM(L-ROW, 1) L-INDEX WS-ITEM WS-COUNT
         END-IF
     END-IF
     MOVE WS-ITEM TO MN-RESULT-ITEM(L-ROW)
     MOVE WS-COUNT TO MN-RESULT-COUNT(L-ROW)
     MOVE 0 TO MN-RESULT-VAR(L-ROW)
     GOBACK.
 END PROGRAM MENU-STONE-SETUP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-STATION-UPDATE.
*> USING row: slotsChanged of the station. The stonecutter (40-4 section 4.4): the list and the selection reset when the kind of the input item
*> differs from the one remembered, the selection is data slot 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CMENU.
 01 WS-DIFF                BINARY-LONG.
 01 WS-HAS                 BINARY-LONG.
 01 WS-SIZE                BINARY-LONG.
 01 WS-RESET               BINARY-LONG.
 01 WS-NSEL                BINARY-LONG.
 01 WS-CLEARED             BINARY-LONG.
 01 WS-FROMSET             BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     IF MN-CFAMILY(L-ROW) = 21
         MOVE 0 TO WS-ITEM
         IF MN-WSLOT-COUNT(L-ROW, 1) > 0
             MOVE MN-WSLOT-ITEM(L-ROW, 1) TO WS-ITEM
         END-IF
         MOVE 0 TO WS-DIFF WS-HAS
         IF WS-ITEM NOT = MN-WKEEP(L-ROW)
             MOVE 1 TO WS-DIFF
         END-IF
         IF WS-ITEM > 0
             MOVE 1 TO WS-HAS
         END-IF
         CALL "MN4-STONE-CHANGED" USING WS-DIFF WS-HAS MN-WSEL(L-ROW) WS-RESET WS-NSEL WS-CLEARED WS-FROMSET
         IF WS-RESET = 1
             MOVE WS-ITEM TO MN-WKEEP(L-ROW)
             MOVE WS-NSEL TO MN-WSEL(L-ROW)
             MOVE 0 TO MN-RESULT-ITEM(L-ROW) MN-RESULT-COUNT(L-ROW) MN-RESULT-VAR(L-ROW)
         END-IF
         MOVE MN-WSEL(L-ROW) TO MN-WDATA(L-ROW, 1)
     END-IF
     GOBACK.
 END PROGRAM MENU-STATION-UPDATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-STATION-TAKEN.
*> USING row: the result slot was emptied by a take. Stonecutter (40-4 section 4.6): one item of the input is used up; when the input is then empty the
*> selection resets, else the result is assembled again from the remaining input.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CMENU.
 01 WS-NC                  BINARY-LONG.
 01 WS-NSEL                BINARY-LONG.
 01 WS-RES                 BINARY-LONG.
 01 WS-SIZE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     IF MN-CFAMILY(L-ROW) = 21
         IF MN-WSLOT-COUNT(L-ROW, 1) > 0
             CALL "MENU-STONE-COUNT" USING MN-WSLOT-ITEM(L-ROW, 1) WS-SIZE
             CALL "MN4-STONE-TAKE" USING MN-WSLOT-COUNT(L-ROW, 1) MN-WSEL(L-ROW) WS-SIZE WS-NC WS-NSEL WS-RES
             MOVE WS-NC TO MN-WSLOT-COUNT(L-ROW, 1)
             IF WS-NC = 0
                 MOVE 0 TO MN-WSLOT-ITEM(L-ROW, 1) MN-WSLOT-VAR(L-ROW, 1)
             END-IF
             CALL "MENU-STATION-UPDATE" USING L-ROW
             IF WS-NC > 0
                 CALL "MENU-STONE-SETUP" USING L-ROW MN-WSEL(L-ROW)
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM MENU-STATION-TAKEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-STATION-QUICK.
*> USING row, menu slot, item out, count out: quickMoveStack of the station menus. The stonecutter's table is 40-4 section 4.7 (MN4-STONE-QUICK).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CMENU.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-VAR                 BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 01 WS-MOVED               BINARY-LONG.
 01 WS-ACC                 BINARY-LONG.
 01 WS-SIZE                BINARY-LONG.
 01 WS-RULE                BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-END                 BINARY-LONG.
 01 WS-REV                 BINARY-LONG.
 01 WS-ONQ                 BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
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
     IF MN-CFAMILY(L-ROW) = 21
         CALL "MENU-STONE-COUNT" USING WS-ITEM WS-SIZE
         MOVE 0 TO WS-ACC
         IF WS-SIZE > 0
             MOVE 1 TO WS-ACC
         END-IF
         CALL "MN4-STONE-QUICK" USING L-SLOT WS-ACC WS-RULE WS-FIRST WS-END WS-REV WS-ONQ
         MOVE WS-COUNT TO WS-LEFT
         MOVE 0 TO WS-MOVED
         CALL "MENU-MOVE-TO-X" USING L-ROW WS-ITEM WS-LEFT WS-FIRST WS-END WS-REV WS-MOVED WS-VAR
         IF WS-MOVED = 0
             GOBACK
         END-IF
         IF L-SLOT = 1
             IF WS-LEFT > 0
                 CALL "GI-THROW-STACK-X" USING L-ROW WS-ITEM WS-LEFT WS-VAR
             END-IF
             CALL "MENU-SET-X" USING L-ROW L-SLOT WS-ITEM WS-ZERO WS-VAR
             CALL "MENU-STATION-TAKEN" USING L-ROW
             MOVE WS-ITEM TO L-RET-ITEM
             MOVE WS-COUNT TO L-RET-COUNT
         ELSE
             CALL "MENU-QUICK-FINISH" USING L-ROW L-SLOT WS-ITEM WS-COUNT WS-LEFT WS-MOVED L-RET-ITEM L-RET-COUNT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM MENU-STATION-QUICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-STATION-STOP.
*> USING row: the close of a station menu: every input slot goes back to the player (what does not fit is thrown), the result slot is dropped with
*> the menu (40-4 section 1 rule 4), the station state is reset.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CMENU.
 01 WS-I                   BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-VAR                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         IF MN-WSLOT-COUNT(L-ROW, WS-I) > 0
             MOVE MN-WSLOT-ITEM(L-ROW, WS-I) TO WS-ITEM
             MOVE MN-WSLOT-COUNT(L-ROW, WS-I) TO WS-COUNT
             MOVE MN-WSLOT-VAR(L-ROW, WS-I) TO WS-VAR
             MOVE 0 TO MN-WSLOT-ITEM(L-ROW, WS-I) MN-WSLOT-COUNT(L-ROW, WS-I) MN-WSLOT-VAR(L-ROW, WS-I)
             CALL "MENU-RETURN-STACK-X" USING L-ROW WS-ITEM WS-COUNT WS-VAR
         END-IF
     END-PERFORM
     MOVE 0 TO MN-RESULT-ITEM(L-ROW) MN-RESULT-COUNT(L-ROW) MN-RESULT-VAR(L-ROW)
     MOVE 0 TO MN-WRES(L-ROW)
     GOBACK.
 END PROGRAM MENU-STATION-STOP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-STATION-SYNC.
*> USING row: Container Set Data (05a 0x13) for every data slot of the open station menu whose value differs from the one last sent.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CMENU.
 COPY PROTO.
 01 WS-READY               PIC 9 VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 16.
 01 WS-PACKET-ID           BINARY-LONG VALUE 19.
 01 WS-I                   BINARY-LONG.
 01 WS-PROPERTY            BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     IF MN-WINDOW(L-ROW) = 0 OR MN-CFAMILY(L-ROW) < 20
         GOBACK
     END-IF
*>   The stonecutter's list is the stonecutter entries of the latest Update Recipes the client holds: sent when the input item differs from the last list.
     IF MN-CFAMILY(L-ROW) = 21 AND MN-WKEEP(L-ROW) NOT = MN-WLIST(L-ROW)
         MOVE MN-WKEEP(L-ROW) TO MN-WLIST(L-ROW)
         CALL "RECIPES-UPDATE-SEND-FOR" USING PL-CONN(L-ROW) MN-WKEEP(L-ROW)
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
         IF MN-WDATA(L-ROW, WS-I) NOT = MN-WSENT(L-ROW, WS-I)
             MOVE MN-WDATA(L-ROW, WS-I) TO MN-WSENT(L-ROW, WS-I)
             COMPUTE WS-PROPERTY = WS-I - 1
             CALL "PB-RESET" USING PB-BUFFER
             CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
             CALL "PB-PUT-CONTAINER-SET-DATA" USING PB-BUFFER MN-WINDOW(L-ROW) WS-PROPERTY MN-WDATA(L-ROW, WS-I)
             CALL "CORE-SEND" USING PL-CONN(L-ROW) PB-BUFFER
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM MENU-STATION-SYNC.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-STATION-BUTTON.
*> USING row, button id, returned out: clickMenuButton of the station. Stonecutter (40-4 section 4.5): selecting another entry of the list selects it
*> and sets up its result; returned is 1 whenever the id differs from the selected one (an out of range id changes nothing).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CMENU.
 01 WS-SIZE                BINARY-LONG.
 01 WS-SET                 BINARY-LONG.
 01 WS-SETUP               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-BUTTON               BINARY-LONG.
 01 L-RETURNED             BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-BUTTON L-RETURNED.
     MOVE 0 TO L-RETURNED
     IF MN-CFAMILY(L-ROW) = 21
         MOVE 0 TO WS-SIZE
         IF MN-WSLOT-COUNT(L-ROW, 1) > 0
             CALL "MENU-STONE-COUNT" USING MN-WSLOT-ITEM(L-ROW, 1) WS-SIZE
         END-IF
         CALL "MN4-STONE-BUTTON" USING L-BUTTON MN-WSEL(L-ROW) WS-SIZE L-RETURNED WS-SET WS-SETUP
         IF WS-SET = 1
             MOVE L-BUTTON TO MN-WSEL(L-ROW)
             MOVE L-BUTTON TO MN-WDATA(L-ROW, 1)
         END-IF
         IF WS-SETUP = 1
             CALL "MENU-STONE-SETUP" USING L-ROW L-BUTTON
         END-IF
     END-IF
     GOBACK.
 END PROGRAM MENU-STATION-BUTTON.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STATION-BUTTON.
*> USING connection id, PLAY-SERVERBOUND (a decoded Container Button Click): the click of a button of the player's open station menu. Another container
*> id than the current one, or a menu that is not a station, is ignored. The slots the click changed are sent with a raised state id, the data slots
*> that changed with Container Set Data.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CMENU.
 01 WS-ROW                 BINARY-LONG.
 01 WS-LIMIT               BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-RET                 BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-VAR                 BINARY-LONG.
 01 WS-CHANGED             BINARY-LONG.
 01 WS-OLD                 BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-BEFORE.
    05 WS-BEFORE-SLOT OCCURS 90 TIMES.
       10 WS-BEFORE-ITEM   BINARY-LONG.
       10 WS-BEFORE-COUNT  BINARY-LONG.
       10 WS-BEFORE-VAR    BINARY-LONG.
 LINKAGE SECTION.
 COPY PLAYPKT.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ID PLAY-SERVERBOUND.
     MOVE CN-PLAYER(L-ID) TO WS-ROW
     IF MN-WINDOW(WS-ROW) = 0 OR PSB-CONTAINER NOT = MN-WINDOW(WS-ROW) OR MN-CFAMILY(WS-ROW) < 20
         GOBACK
     END-IF
     CALL "MENU-SLOT-COUNT" USING WS-ROW WS-LIMIT
     PERFORM VARYING WS-S FROM 0 BY 1 UNTIL WS-S >= WS-LIMIT
         CALL "MENU-GET-X" USING WS-ROW WS-S WS-BEFORE-ITEM(WS-S + 1) WS-BEFORE-COUNT(WS-S + 1) WS-BEFORE-VAR(WS-S + 1)
     END-PERFORM
     CALL "MENU-STATION-BUTTON" USING WS-ROW PSB-BUTTON WS-RET
     MOVE 0 TO WS-CHANGED
     PERFORM VARYING WS-S FROM 0 BY 1 UNTIL WS-S >= WS-LIMIT
         CALL "MENU-GET-X" USING WS-ROW WS-S WS-ITEM WS-COUNT WS-VAR
         IF WS-ITEM NOT = WS-BEFORE-ITEM(WS-S + 1) OR WS-COUNT NOT = WS-BEFORE-COUNT(WS-S + 1)
                 OR WS-VAR NOT = WS-BEFORE-VAR(WS-S + 1)
             MOVE 1 TO WS-CHANGED
         END-IF
     END-PERFORM
     IF WS-CHANGED = 1
         CALL "MENU-STATE-RAISE" USING WS-ROW WS-OLD WS-NEW
         PERFORM VARYING WS-S FROM 0 BY 1 UNTIL WS-S >= WS-LIMIT
             CALL "MENU-GET-X" USING WS-ROW WS-S WS-ITEM WS-COUNT WS-VAR
             IF WS-ITEM NOT = WS-BEFORE-ITEM(WS-S + 1) OR WS-COUNT NOT = WS-BEFORE-COUNT(WS-S + 1)
                     OR WS-VAR NOT = WS-BEFORE-VAR(WS-S + 1)
                 CALL "MENU-SLOT-SEND" USING L-ID WS-S
             END-IF
         END-PERFORM
     END-IF
     CALL "MENU-STATION-SYNC" USING WS-ROW
     GOBACK.
 END PROGRAM STATION-BUTTON.
