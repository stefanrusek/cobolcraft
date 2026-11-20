*> The workstation menus in the live window of a player (docs/protocol/40-menus-1-model-and-containers.md, 40-menus-3 and 40-menus-4; 002-lane-stations,
*> T5200 and on): stonecutter, grindstone, smithing table, anvil, loom, cartography table, enchanting table and brewing stand. A workstation menu is a
*> container menu (MN-CSIZE > 0) whose own slots are kept in the player's menu row (MN-WSLOT, the result slot in MN-RESULT-*): MN-CFAMILY is 20 + the
*> station kind below, MN-WRES the own slot that is the result slot (MENU-LOCATE names it as the result slot, kind 4, so the take rules of the result
*> slot are the bench's: the whole stack leaves, MENU-RESULT-TAKEN is called, nothing may be placed). The pure rules of the documents are the MN2- to MN4-
*> and ENCH- programs of menu-40-2.cob to menu-enchanting.cob; this file reads the live state, calls them and applies what they decide.
*>
*> Station kinds: 1 stonecutter, 2 grindstone, 3 smithing table, 4 anvil, 5 loom, 6 cartography table, 7 enchanting table, 8 brewing stand. MENU-STATION-KIND
*> names the stations that are built: the stonecutter, grindstone, smithing table, anvil, enchanting table, loom (menu-loom.cob) and cartography table (menu-cartography.cob);
*> a block of another kind (the brewing stand) does not open a menu yet.
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
         WHEN "smithing_table"
             MOVE 3 TO L-KIND
         WHEN "enchanting_table"
             MOVE 7 TO L-KIND
         WHEN "grindstone"
             MOVE 2 TO L-KIND
         WHEN "loom"
             MOVE 5 TO L-KIND
         WHEN "cartography_table"
             MOVE 6 TO L-KIND
         WHEN "anvil"
             MOVE 4 TO L-KIND
         WHEN "chipped_anvil"
             MOVE 4 TO L-KIND
         WHEN "damaged_anvil"
             MOVE 4 TO L-KIND
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
         WHEN 9
*>           The merchant (40-5 section 2.1: type 19, 3 own slots, the result is own slot 2; the title is the villager's name).
             MOVE 19 TO L-TYPE
             MOVE 3 TO L-OWN
             MOVE 2 TO L-RESULT
             MOVE "entity.minecraft.villager" TO WS-T1
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
     MOVE 0 TO MN-WNAME-LEN(WS-ROW)
     MOVE SPACES TO MN-WNAME(WS-ROW)
     MOVE 0 TO MN-WKEEP(WS-ROW) MN-WSOUND(WS-ROW)
     MOVE -1 TO MN-WLIST(WS-ROW)
     MOVE 0 TO MN-RESULT-ITEM(WS-ROW) MN-RESULT-COUNT(WS-ROW) MN-RESULT-VAR(WS-ROW)
     IF L-KIND = 7
         CALL "MENU-ENCH-OPEN" USING WS-ROW
     END-IF
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
*> USING row, own slot, item, result out: the stonecutter's input slot takes any item (40-4 section 4.2); the smithing table's slot s takes the items of the
*> ingredient s of the smithing recipes (40-3 section 5.1: the sets smithing_template, smithing_base, smithing_addition).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CMENU.
 01 WS-SET                 BINARY-LONG.
 01 WS-LAPIS               BINARY-LONG.
 01 WS-DAMAGEABLE          BINARY-LONG.
 01 WS-ENCHANTED           BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-HANDLE               BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-ITEM L-HANDLE L-RESULT.
     MOVE 1 TO L-RESULT
     IF MN-CFAMILY(L-ROW) = 23
         COMPUTE WS-SET = L-SLOT + 1
         CALL "MENU-SMITH-SET" USING WS-SET L-ITEM L-RESULT
     END-IF
*>   The grindstone's inputs take a damageable stack or one with enchantments (40-3 section 4.1).
     IF MN-CFAMILY(L-ROW) = 22 AND L-SLOT < 2
         CALL "GRIND-DAMAGEABLE" USING L-ITEM L-HANDLE WS-DAMAGEABLE
         CALL "GRIND-HAS-ENCH" USING L-HANDLE WS-ENCHANTED
         CALL "MN3-GRIND-MAYPLACE" USING WS-DAMAGEABLE WS-ENCHANTED L-RESULT
     END-IF
*>   The cartography table's map and additional slots (40-4 section 5.2).
     IF MN-CFAMILY(L-ROW) = 26
         CALL "MENU-CARTO-MAYPLACE" USING L-SLOT L-ITEM L-HANDLE L-RESULT
     END-IF
*>   The loom's banner, dye and pattern slots (40-4 section 3.2).
     IF MN-CFAMILY(L-ROW) = 25
         CALL "MENU-LOOM-MAYPLACE" USING L-SLOT L-ITEM L-RESULT
     END-IF
*>   The enchanting table's lapis slot takes only lapis lazuli (40-4 section 2.2).
     IF MN-CFAMILY(L-ROW) = 27
         CALL "ENCH-IS-LAPIS" USING L-ITEM WS-LAPIS
         CALL "ENCH-MAYPLACE" USING L-SLOT WS-LAPIS L-RESULT
     END-IF
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
 PROGRAM-ID. MENU-SMITH-SET.
*> USING ingredient number (1 template, 2 base, 3 addition), item, ok out: the item is in the property set of that ingredient: the union of the
*> ingredient items of the smithing recipes (smithing_transform and smithing_trim, serializers 19 and 21 of the recipe store) (40-3 section 5.1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTRECIPE.
 01 WS-K                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-N                    BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-N L-ITEM L-RESULT.
     MOVE 0 TO L-RESULT
     IF L-ITEM <= 0
         GOBACK
     END-IF
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > RC-COUNT OR L-RESULT = 1
         IF (RR-SERIALIZER(WS-K) = 19 OR RR-SERIALIZER(WS-K) = 21) AND RR-ING(WS-K, L-N) NOT = SPACES
             CALL "CRAFT-ING-TEST" USING L-ITEM RR-ING(WS-K, L-N) WS-OK
             IF WS-OK = 1
                 MOVE 1 TO L-RESULT
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM MENU-SMITH-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-SMITH-MATCH.
*> USING row, result item out, result count out, result patch out (the base's: smithing_transform copies the components of the base, 40-3 section
*> 5.3 and 27 section 3.3): the first smithing_transform recipe in store order whose template, base and addition ingredients each take their slot (an
*> absent ingredient needs an empty slot). 0 when none.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CMENU.
 COPY CTRECIPE.
 COPY CONTENT.
 01 WS-K                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ROW-X               PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-BASE-I              BINARY-LONG.
 01 WS-BASE-V              BINARY-LONG.
 01 WS-ADD-I               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-VAR                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ITEM L-COUNT L-VAR.
     MOVE 0 TO L-ITEM L-COUNT L-VAR
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > RC-COUNT OR L-ITEM > 0
         IF RR-SERIALIZER(WS-K) = 19 OR RR-SERIALIZER(WS-K) = 21
             MOVE 1 TO WS-OK
             PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 3
                 IF RR-ING(WS-K, WS-S) = SPACES
                     IF MN-WSLOT-COUNT(L-ROW, WS-S) > 0
                         MOVE 0 TO WS-OK
                     END-IF
                 ELSE
                     IF MN-WSLOT-COUNT(L-ROW, WS-S) = 0
                         MOVE 0 TO WS-OK
                     ELSE
                         CALL "CRAFT-ING-TEST" USING MN-WSLOT-ITEM(L-ROW, WS-S) RR-ING(WS-K, WS-S) WS-STATUS
                         IF WS-STATUS = 0
                             MOVE 0 TO WS-OK
                         END-IF
                     END-IF
                 END-IF
             END-PERFORM
             IF WS-OK = 1 AND RR-SERIALIZER(WS-K) = 21
*>               smithing_trim (27 section 3.3, 54 section 18.6): one copy of the base with the trim of the pattern and the addition's material.
                 MOVE MN-WSLOT-ITEM(L-ROW, 2) TO WS-BASE-I
                 MOVE MN-WSLOT-VAR(L-ROW, 2) TO WS-BASE-V
                 MOVE MN-WSLOT-ITEM(L-ROW, 3) TO WS-ADD-I
                 CALL "SMITH-TRIM-RESULT" USING RR-EXTRA(WS-K) WS-BASE-I WS-BASE-V WS-ADD-I L-VAR WS-STATUS
                 IF WS-STATUS = 1
                     MOVE MN-WSLOT-ITEM(L-ROW, 2) TO L-ITEM
                     MOVE 1 TO L-COUNT
                 ELSE
                     MOVE 0 TO L-VAR
                 END-IF
             END-IF
             IF WS-OK = 1 AND RR-SERIALIZER(WS-K) = 19
                 MOVE RR-RESULT-ID(WS-K) TO WS-KEY
                 CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY L-ITEM WS-ROW-X WS-STATUS
                 IF WS-STATUS = CT-OK
                     COMPUTE L-COUNT = FUNCTION MAX(RR-RESULT-COUNT(WS-K), 1)
                     MOVE MN-WSLOT-VAR(L-ROW, 2) TO L-VAR
                 ELSE
                     MOVE 0 TO L-ITEM
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM MENU-SMITH-MATCH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-STATION-COMBINER-QUICK.
*> USING row, menu slot, result slot R, can move into the inputs (1 or 0), item out, count out: quickMoveStack of the item combiner base, 40-3 section 2.5
*> (MN3-COMBINER-QUICK): the result moves to the inventory from the end (what does not fit is thrown, the take is run), an input to the inventory, an
*> inventory stack to the inputs when it can go there, else between the main inventory and the hotbar.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CMENU.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-VAR                 BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 01 WS-MOVED               BINARY-LONG.
 01 WS-BRANCH              BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-END                 BINARY-LONG.
 01 WS-REV                 BINARY-LONG.
 01 WS-ONQ                 BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-R                    BINARY-LONG.
 01 L-CAN                  BINARY-LONG.
 01 L-RET-ITEM             BINARY-LONG.
 01 L-RET-COUNT            BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-R L-CAN L-RET-ITEM L-RET-COUNT.
     MOVE 0 TO L-RET-ITEM L-RET-COUNT
*>   The slot holds a stack (the calling station checked).
     CALL "MENU-GET-X" USING L-ROW L-SLOT WS-ITEM WS-COUNT WS-VAR
     CALL "MN3-COMBINER-QUICK" USING L-R L-SLOT L-CAN WS-BRANCH WS-FIRST WS-END WS-REV WS-ONQ
     MOVE WS-COUNT TO WS-LEFT
     MOVE 0 TO WS-MOVED
     CALL "MENU-MOVE-TO-X" USING L-ROW WS-ITEM WS-LEFT WS-FIRST WS-END WS-REV WS-MOVED WS-VAR
     IF WS-MOVED = 0
         GOBACK
     END-IF
     IF L-SLOT = L-R
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
     GOBACK.
 END PROGRAM MENU-STATION-COMBINER-QUICK.

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
 01 WS-RCOUNT              BINARY-LONG.
 01 WS-RVAR                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     IF MN-CFAMILY(L-ROW) = 29
         CALL "MERCHANT-UPDATE" USING L-ROW
     END-IF
*>   The smithing table (40-3 section 5.2 and 5.3): the result of the first matching recipe, the error flag when the three inputs are full and no recipe fits.
     IF MN-CFAMILY(L-ROW) = 23
         CALL "MENU-SMITH-MATCH" USING L-ROW WS-ITEM WS-RCOUNT WS-RVAR
         MOVE WS-ITEM TO MN-RESULT-ITEM(L-ROW)
         MOVE WS-RCOUNT TO MN-RESULT-COUNT(L-ROW)
         MOVE WS-RVAR TO MN-RESULT-VAR(L-ROW)
         MOVE 0 TO MN-WDATA(L-ROW, 1)
         IF WS-ITEM = 0 AND MN-WSLOT-COUNT(L-ROW, 1) > 0 AND MN-WSLOT-COUNT(L-ROW, 2) > 0 AND MN-WSLOT-COUNT(L-ROW, 3) > 0
             MOVE 1 TO MN-WDATA(L-ROW, 1)
         END-IF
     END-IF
     IF MN-CFAMILY(L-ROW) = 24
         CALL "MENU-ANVIL-UPDATE" USING L-ROW
     END-IF
     IF MN-CFAMILY(L-ROW) = 25
         CALL "MENU-LOOM-UPDATE" USING L-ROW
     END-IF
     IF MN-CFAMILY(L-ROW) = 26
         CALL "MENU-CARTO-UPDATE" USING L-ROW
     END-IF
     IF MN-CFAMILY(L-ROW) = 27
         CALL "MENU-ENCH-UPDATE" USING L-ROW
     END-IF
     IF MN-CFAMILY(L-ROW) = 22
         CALL "MENU-GRIND-UPDATE" USING L-ROW
     END-IF
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
 PROGRAM-ID. STATION-SOUND.
*> USING dimension row, block x, y, z (BINARY-LONG), sound key (PIC X(112), with namespace): Level.playSound(null, pos, event, BLOCKS, 1.0, 1.0) of a workstation take (57-client-closures-2 section 3.2):
*> one Clientbound Sound (0x77: the registry id + 1, source blocks, the block centre in eighths, volume 1.0, pitch 1.0, seed 0) to every player of the dimension whose own position is
*> closer than 16 blocks (a 3D sphere, strict) to the block centre, the taker included.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-REGISTRY            PIC X(48) VALUE "minecraft:sound_event".
 01 WS-PACKET-ID           BINARY-LONG VALUE 119.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-ID                  BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-HOLDER              BINARY-LONG.
 01 WS-SOURCE              BINARY-LONG VALUE 4.
 01 WS-FX                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-VOLUME              FLOAT-SHORT VALUE 1.0.
 01 WS-PITCH               FLOAT-SHORT VALUE 1.0.
 01 WS-SEED                BINARY-DOUBLE VALUE 0.
 01 WS-P                   BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-KEY                  PIC X(112).
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-KEY.
     CALL "CONTENT-STATIC-ID" USING WS-REGISTRY L-KEY WS-ID WS-STATUS
     COMPUTE WS-HOLDER = WS-ID + 1
     COMPUTE WS-FX = L-X * 8 + 4
     COMPUTE WS-FY = L-Y * 8 + 4
     COMPUTE WS-FZ = L-Z * 8 + 4
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-HOLDER
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-SOURCE
     CALL "PB-PUT-INT" USING PB-BUFFER WS-FX
     CALL "PB-PUT-INT" USING PB-BUFFER WS-FY
     CALL "PB-PUT-INT" USING PB-BUFFER WS-FZ
     CALL "PB-PUT-FLOAT" USING PB-BUFFER WS-VOLUME
     CALL "PB-PUT-FLOAT" USING PB-BUFFER WS-PITCH
     CALL "PB-PUT-LONG" USING PB-BUFFER WS-SEED
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
         IF PL-USED(WS-P) = 1 AND PL-DIM(WS-P) = L-DIM
             COMPUTE WS-DX = PL-X(WS-P) - L-X - 0.5
             COMPUTE WS-DY = PL-Y(WS-P) - L-Y - 0.5
             COMPUTE WS-DZ = PL-Z(WS-P) - L-Z - 0.5
             IF WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ < 256
                 CALL "CORE-SEND" USING PL-CONN(WS-P) PB-BUFFER
             END-IF
         END-IF
     END-PERFORM
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM STATION-SOUND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-STATION-TAKEN.
*> USING row: the result slot was emptied by a take. Stonecutter (40-4 section 4.6): one item of the input is used up; when the input is then empty the
*> selection resets, else the result is assembled again from the remaining input.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CMENU.
 01 WS-NC                  BINARY-LONG.
 01 WS-NSEL                BINARY-LONG.
 01 WS-RES                 BINARY-LONG.
 01 WS-SIZE                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-C0                  BINARY-LONG.
 01 WS-C1                  BINARY-LONG.
 01 WS-C2                  BINARY-LONG.
 01 WS-N0                  BINARY-LONG.
 01 WS-N1                  BINARY-LONG.
 01 WS-N2                  BINARY-LONG.
 01 WS-EVENT               BINARY-LONG.
 01 WS-PLAY                BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-STONE-SOUND         PIC X(112) VALUE "minecraft:ui.stonecutter.take_result".
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-NONE2               BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     IF MN-CFAMILY(L-ROW) = 29
         CALL "MERCHANT-TAKEN" USING L-ROW
     END-IF
     IF MN-CFAMILY(L-ROW) = 24
         CALL "MENU-ANVIL-TAKEN" USING L-ROW
     END-IF
     IF MN-CFAMILY(L-ROW) = 22
         CALL "MENU-GRIND-TAKEN" USING L-ROW
     END-IF
     IF MN-CFAMILY(L-ROW) = 25
         CALL "MENU-LOOM-TAKEN" USING L-ROW
     END-IF
     IF MN-CFAMILY(L-ROW) = 26
         CALL "MENU-CARTO-TAKEN" USING L-ROW
     END-IF
*>   The smithing table (40-3 section 5.4): one item of each of the three inputs is used up, then the result is made again.
     IF MN-CFAMILY(L-ROW) = 23
         MOVE MN-WSLOT-COUNT(L-ROW, 1) TO WS-C0
         MOVE MN-WSLOT-COUNT(L-ROW, 2) TO WS-C1
         MOVE MN-WSLOT-COUNT(L-ROW, 3) TO WS-C2
         CALL "MN3-SMITH-TAKE" USING WS-C0 WS-C1 WS-C2 WS-N0 WS-N1 WS-N2 WS-EVENT
         CALL "LEVEL-EVENT" USING MN-BENCH-DIM(L-ROW) WS-EVENT MN-BENCH-X(L-ROW) MN-BENCH-Y(L-ROW) MN-BENCH-Z(L-ROW)
             WS-NONE WS-NONE2
         MOVE WS-N0 TO MN-WSLOT-COUNT(L-ROW, 1)
         MOVE WS-N1 TO MN-WSLOT-COUNT(L-ROW, 2)
         MOVE WS-N2 TO MN-WSLOT-COUNT(L-ROW, 3)
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
             IF MN-WSLOT-COUNT(L-ROW, WS-I) = 0
                 MOVE 0 TO MN-WSLOT-ITEM(L-ROW, WS-I) MN-WSLOT-VAR(L-ROW, WS-I)
             END-IF
         END-PERFORM
         CALL "MENU-STATION-UPDATE" USING L-ROW
     END-IF
     IF MN-CFAMILY(L-ROW) = 21
*>       The take sound (57-client-closures-2 section 3.2): once per game tick per menu (40-4 section 1 rule 5).
         CALL "MN4-SOUND" USING CW-TICKS MN-WSOUND(L-ROW) WS-PLAY WS-LAST
         IF WS-PLAY = 1
             MOVE WS-LAST TO MN-WSOUND(L-ROW)
             CALL "STATION-SOUND" USING MN-BENCH-DIM(L-ROW) MN-BENCH-X(L-ROW) MN-BENCH-Y(L-ROW) MN-BENCH-Z(L-ROW) WS-STONE-SOUND
         END-IF
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
 PROGRAM-ID. MENU-SMITH-QUICK.
*> USING row, menu slot, item out, count out: quickMoveStack of the smithing table (40-3 section 5.4): canMoveIntoInputSlots is a set that takes the stack
*> while its slot is empty; the rest is the combiner's (MENU-STATION-COMBINER-QUICK, R = 3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CMENU.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-VAR                 BINARY-LONG.
 01 WS-R                   BINARY-LONG VALUE 3.
 01 WS-CAN                 BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-N1                  BINARY-LONG VALUE 1.
 01 WS-N2                  BINARY-LONG VALUE 2.
 01 WS-N3                  BINARY-LONG VALUE 3.
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
     CALL "MENU-SMITH-SET" USING WS-N1 WS-ITEM WS-T
     CALL "MENU-SMITH-SET" USING WS-N2 WS-ITEM WS-B
     CALL "MENU-SMITH-SET" USING WS-N3 WS-ITEM WS-A
     MOVE 0 TO WS-CAN
     IF (WS-T = 1 AND MN-WSLOT-COUNT(L-ROW, 1) = 0) OR (WS-B = 1 AND MN-WSLOT-COUNT(L-ROW, 2) = 0)
             OR (WS-A = 1 AND MN-WSLOT-COUNT(L-ROW, 3) = 0)
         MOVE 1 TO WS-CAN
     END-IF
     CALL "MENU-STATION-COMBINER-QUICK" USING L-ROW L-SLOT WS-R WS-CAN L-RET-ITEM L-RET-COUNT
     GOBACK.
 END PROGRAM MENU-SMITH-QUICK.

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
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-RET-ITEM             BINARY-LONG.
 01 L-RET-COUNT            BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-RET-ITEM L-RET-COUNT.
     MOVE 0 TO L-RET-ITEM L-RET-COUNT
*>   The merchant's rules are 40-5 section 2.8.
     IF MN-CFAMILY(L-ROW) = 29
         CALL "MERCHANT-QUICK" USING L-ROW L-SLOT L-RET-ITEM L-RET-COUNT
         GOBACK
     END-IF
*>   The grindstone's rules are 40-3 section 4.5.
     IF MN-CFAMILY(L-ROW) = 22
         CALL "MENU-GRIND-QUICK" USING L-ROW L-SLOT L-RET-ITEM L-RET-COUNT
         GOBACK
     END-IF
*>   The cartography table's rules are 40-4 section 5.5.
     IF MN-CFAMILY(L-ROW) = 26
         CALL "MENU-CARTO-QUICK" USING L-ROW L-SLOT L-RET-ITEM L-RET-COUNT
         GOBACK
     END-IF
*>   The loom's rules are 40-4 section 3.8.
     IF MN-CFAMILY(L-ROW) = 25
         CALL "MENU-LOOM-QUICK" USING L-ROW L-SLOT L-RET-ITEM L-RET-COUNT
         GOBACK
     END-IF
*>   The enchanting table's rules are 40-4 section 2.7.
     IF MN-CFAMILY(L-ROW) = 27
         CALL "MENU-ENCH-QUICK" USING L-ROW L-SLOT L-RET-ITEM L-RET-COUNT
         GOBACK
     END-IF
*>   The smithing table is its own program (the item combiner rules, 40-3 section 2.5).
     IF MN-CFAMILY(L-ROW) = 23
         CALL "MENU-SMITH-QUICK" USING L-ROW L-SLOT L-RET-ITEM L-RET-COUNT
         GOBACK
     END-IF
     CALL "MENU-GET-X" USING L-ROW L-SLOT WS-ITEM WS-COUNT WS-VAR
     IF WS-COUNT = 0
         GOBACK
     END-IF
*>   The anvil is an item combiner (40-3 section 3.6): the result is slot 2, the inputs take any stack.
     IF MN-CFAMILY(L-ROW) = 24
         CALL "MENU-STATION-COMBINER-QUICK" USING L-ROW L-SLOT WS-TWO WS-ONE L-RET-ITEM L-RET-COUNT
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
 01 WS-VALUE               BINARY-LONG.
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
             MOVE MN-WDATA(L-ROW, WS-I) TO WS-VALUE
*>           The enchanting table's seed (data slot 3) travels as a short: its low 16 bits, signed (40-4 section 2.3).
             IF MN-CFAMILY(L-ROW) = 27 AND WS-I = 4
                 COMPUTE WS-VALUE = FUNCTION MOD(WS-VALUE, 65536)
                 IF WS-VALUE >= 32768
                     SUBTRACT 65536 FROM WS-VALUE
                 END-IF
             END-IF
             COMPUTE WS-PROPERTY = WS-I - 1
             CALL "PB-RESET" USING PB-BUFFER
             CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
             CALL "PB-PUT-CONTAINER-SET-DATA" USING PB-BUFFER MN-WINDOW(L-ROW) WS-PROPERTY WS-VALUE
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
     IF MN-CFAMILY(L-ROW) = 27
         CALL "MENU-ENCH-BUTTON" USING L-ROW L-BUTTON L-RETURNED
     END-IF
     IF MN-CFAMILY(L-ROW) = 25
         CALL "MENU-LOOM-BUTTON" USING L-ROW L-BUTTON L-RETURNED
     END-IF
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
