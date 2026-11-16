*> Acceptance test, crafting with components through the live menu (docs/protocol/27 section 2.5 and 2.6; lane itemcomp2, T10101): in the 2 x 2 grid of the inventory menu a
*> leather helmet and a red dye give a dyed helmet whose result slot carries the dyed_color patch (MN-RESULT-VAR), taking the result uses up the dye and the helmet and clears
*> the handles; two white banners, one patterned, give the patterned banner and the source stays in its slot. The recipe rows are the ones of the standard world.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-ITEMCOMP-CRAFT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CMENU.
 COPY CITEMS.
 COPY CTRECIPE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-HELMET              BINARY-LONG.
 01 WS-HANDLE              BINARY-LONG.
 01 WS-RGB                 BINARY-LONG.
 01 WS-HAS                 BINARY-LONG.
 01 WS-LAYERS              BINARY-LONG.
 01 WS-PATTERN             BINARY-LONG.
 01 WS-DYE                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-E4                  PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "T" TO TL-MODE
*>   The recipe rows under test (the store of the test world is empty).
     MOVE 0 TO RC-COUNT
     ADD 1 TO RC-COUNT
     MOVE RC-COUNT TO WS-ROW
     INITIALIZE RC-ROW(WS-ROW)
     MOVE "minecraft:leather_helmet_dyed" TO RR-KEY(WS-ROW)
     MOVE 2 TO RR-SERIALIZER(WS-ROW)
     MOVE "minecraft:leather_helmet" TO RR-ING(WS-ROW, 1) RR-RESULT-ID(WS-ROW)
     MOVE "minecraft:white_dye minecraft:orange_dye minecraft:magenta_dye minecraft:light_blue_dye minecraft:yellow_dye minecraft:lime_dye minecraft:pink_dye minecraft:gray_dye minecraft:light_gray_dye minecraft:cyan_dye minecraft:purple_dye minecraft:blue_dye minecraft:brown_dye minecraft:green_dye minecraft:red_dye minecraft:black_dye" TO RR-ING(WS-ROW, 2)
     MOVE 1 TO RR-RESULT-COUNT(WS-ROW)
     ADD 1 TO RC-COUNT
     MOVE RC-COUNT TO WS-ROW
     INITIALIZE RC-ROW(WS-ROW)
     MOVE "minecraft:white_banner_duplicate" TO RR-KEY(WS-ROW)
     MOVE 11 TO RR-SERIALIZER(WS-ROW)
     MOVE "minecraft:white_banner" TO RR-ING(WS-ROW, 1) RR-RESULT-ID(WS-ROW)
     MOVE 1 TO RR-RESULT-COUNT(WS-ROW)

     MOVE "acceptance itemcomp 27-2.5 a leather helmet and a red dye in the inventory grid give a dyed helmet with the dyed_color patch on the result slot" TO TL-CASE
     PERFORM CLEAR-GRID
     MOVE "leather_helmet" TO WS-KEY
     PERFORM LOOKUP-ID
     MOVE WS-ID TO WS-HELMET MN-IGRID-ITEM(WS-PLAYER, 1)
     MOVE 1 TO MN-IGRID-COUNT(WS-PLAYER, 1)
     MOVE "red_dye" TO WS-KEY
     PERFORM LOOKUP-ID
     MOVE WS-ID TO MN-IGRID-ITEM(WS-PLAYER, 2)
     MOVE 3 TO MN-IGRID-COUNT(WS-PLAYER, 2)
     CALL "MENU-CRAFT-UPDATE" USING WS-PLAYER
     MOVE MN-RESULT-VAR(WS-PLAYER) TO WS-HANDLE
     CALL "SC-DYE-GET" USING WS-HANDLE WS-RGB WS-HAS
     MOVE MN-RESULT-ITEM(WS-PLAYER) TO WS-E1
     MOVE WS-RGB TO WS-E2
     MOVE WS-HAS TO WS-E3
     MOVE WS-HELMET TO WS-E4
     MOVE SPACES TO TL-OBSERVED TL-EXPECTED
     STRING "item " FUNCTION TRIM(WS-E1) " rgb " FUNCTION TRIM(WS-E2) " has " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO TL-OBSERVED
     STRING "item " FUNCTION TRIM(WS-E4) " rgb 11546150 has 1" DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance itemcomp 27-2.5 taking the dyed helmet uses up the helmet and one dye, the handle of the emptied slot is cleared" TO TL-CASE
     CALL "MENU-RESULT-TAKEN" USING WS-PLAYER
     MOVE MN-IGRID-COUNT(WS-PLAYER, 1) TO WS-E1
     MOVE MN-IGRID-COUNT(WS-PLAYER, 2) TO WS-E2
     MOVE MN-IGRID-VAR(WS-PLAYER, 1) TO WS-E3
     MOVE MN-RESULT-COUNT(WS-PLAYER) TO WS-E4
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) " " FUNCTION TRIM(WS-E4) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "0 2 0 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance itemcomp 27-2.6 two white banners, one with two layers, give the patterned banner and the source stays in the grid" TO TL-CASE
     PERFORM CLEAR-GRID
     MOVE "white_banner" TO WS-KEY
     PERFORM LOOKUP-ID
     MOVE 0 TO WS-HANDLE
     MOVE 3 TO WS-PATTERN
     MOVE 14 TO WS-DYE
     CALL "SC-BANNER-ADD" USING WS-HANDLE WS-PATTERN WS-DYE
     MOVE 9 TO WS-PATTERN
     CALL "SC-BANNER-ADD" USING WS-HANDLE WS-PATTERN WS-DYE
     MOVE WS-ID TO MN-IGRID-ITEM(WS-PLAYER, 1) MN-IGRID-ITEM(WS-PLAYER, 2)
     MOVE 1 TO MN-IGRID-COUNT(WS-PLAYER, 1) MN-IGRID-COUNT(WS-PLAYER, 2)
     MOVE WS-HANDLE TO MN-IGRID-VAR(WS-PLAYER, 2)
     CALL "MENU-CRAFT-UPDATE" USING WS-PLAYER
     MOVE MN-RESULT-VAR(WS-PLAYER) TO WS-I
     CALL "SC-BANNER-COUNT" USING WS-I WS-LAYERS
     MOVE WS-LAYERS TO WS-E1
     CALL "MENU-RESULT-TAKEN" USING WS-PLAYER
     MOVE MN-IGRID-COUNT(WS-PLAYER, 1) TO WS-E2
     MOVE MN-IGRID-COUNT(WS-PLAYER, 2) TO WS-E3
     MOVE MN-IGRID-VAR(WS-PLAYER, 2) TO WS-I
     CALL "SC-BANNER-COUNT" USING WS-I WS-LAYERS
     MOVE WS-LAYERS TO WS-E4
     MOVE SPACES TO TL-OBSERVED
     STRING "result " FUNCTION TRIM(WS-E1) " grid " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) " layers " FUNCTION TRIM(WS-E4)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "result 2 grid 0 1 layers 2" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

 CLEAR-GRID.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         MOVE 0 TO MN-IGRID-ITEM(WS-PLAYER, WS-I) MN-IGRID-COUNT(WS-PLAYER, WS-I) MN-IGRID-VAR(WS-PLAYER, WS-I)
     END-PERFORM.

 LOOKUP-ID.
     MOVE SPACES TO WS-ITEM-ROW
     STRING "minecraft:" FUNCTION TRIM(WS-KEY) DELIMITED BY SIZE INTO WS-ITEM-ROW
     MOVE WS-ITEM-ROW TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ID WS-ITEM-ROW WS-STATUS.

 CHECK.
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-ITEMCOMP-CRAFT.
 COPY MOBSPTEST.
 COPY CORETEST.
