*> The crafting bench screen (US10-2; 12 §5.6b; 13 §3.5; 05a Open Screen 0x3C with menu type 12): Open Screen opens it (INVENTORY-PACKET
*> keeps the container id and clears the bench's slots), Container Set Content and Set Slot of that container fill it. It is the 46-slot
*> menu on the 176 x 166 crafting-table sheet: the result at (124, 35), the 3 x 3 grid at (30 + 18 col, 17 + 18 row), the main inventory
*> at (8 + 18 col, 84 + 18 row) and the hotbar at (8 + 18 i, 142); the title "Crafting" at (29, 6); no armour and no off hand. Clicks, throws and
*> closing are those of the inventory screen with the bench's container id (inventory.cob).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BENCH-BUILD.
*> USING CLIENT-STATE, GUI width, GUI height.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TYPE                BINARY-LONG VALUE 12.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-GW                   BINARY-LONG.
 01 L-GH                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-GW L-GH.
     CALL "MENU-BUILD" USING CLIENT-STATE L-GW L-GH WS-TYPE
     GOBACK.
 END PROGRAM BENCH-BUILD.
