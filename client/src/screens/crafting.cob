*> The crafting screen (US10-1, US10-2; client-surface §3 C; standin-content §13; 08 §10.8.6
*> cobolcraft.screen.crafting.*; 09 §3.3 Recipe Book Add 0x4B, Place Recipe 0x27): its title, then
*> one row per recipe of the recipe book (protocol-client.cob RECIPE-BOOK-READ), in book order:
*> the ingredients ("<count> x <item name>" each, comma-separated, in the order received), under
*> them the result ("Makes <count> x <item name>") and the mark (ready to craft, or missing
*> ingredients), and at the row's right a Craft control, disabled (state 2) for a recipe the server
*> did not mark craftable. Choosing an enabled Craft control sends Place Recipe with the recipe's
*> display id (CRAFTING-CRAFT); the server crafts or does nothing, and its next Recipe Book Add
*> updates the marks. Item names follow 08 §10.8.1: an item that places a block by its block key,
*> any other by its item key.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CRAFTING-BUILD.
*> USING CLIENT-STATE, GUI width, GUI height.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-X0                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-LABEL               BINARY-LONG VALUE WK-LABEL.
 01 WS-BUTTON              BINARY-LONG VALUE WK-BUTTON.
 01 WS-NONE                BINARY-LONG VALUE ACT-NONE.
 01 WS-CRAFT               BINARY-LONG VALUE ACT-CRAFT.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-Z1                  BINARY-LONG VALUE 0.
 01 WS-Z2                  BINARY-LONG VALUE 0.
 01 WS-STATE               BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-H                   BINARY-LONG VALUE 9.
 01 WS-BW                  BINARY-LONG VALUE 55.
 01 WS-BH                  BINARY-LONG VALUE 20.
 01 WS-KEY                 PIC X(80).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-TEXT                PIC X(512).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-LINE                PIC X(512).
 01 WS-LINE-LENGTH         BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-GW                   BINARY-LONG.
 01 L-GH                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-GW L-GH.
     COMPUTE WS-X0 = L-GW / 2 - 170
     COMPUTE WS-Y0 = L-GH / 2 - 92
     COMPUTE WS-Y = WS-Y0 - 12
     MOVE "cobolcraft.screen.crafting.title" TO WS-KEY
     MOVE 32 TO WS-KEY-LENGTH
     CALL "WIDGET-ADD-KEY" USING CLIENT-STATE WS-LABEL WS-NONE WS-X0 WS-Y WS-Z1 WS-Z2 WS-KEY
         WS-KEY-LENGTH
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > RB-COUNT
         COMPUTE WS-Y = WS-Y0 + (WS-R - 1) * 22
*>       The ingredients, comma-separated.
         MOVE SPACES TO WS-LINE
         MOVE 1 TO WS-P
         MOVE "cobolcraft.screen.crafting.ingredient" TO WS-KEY
         MOVE 37 TO WS-KEY-LENGTH
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > RB-IN-COUNT(WS-R)
             IF WS-J > 1
                 STRING ", " DELIMITED BY SIZE INTO WS-LINE WITH POINTER WS-P
             END-IF
             MOVE RB-IN-ITEM(WS-R, WS-J) TO WS-ITEM
             MOVE RB-IN-AMOUNT(WS-R, WS-J) TO WS-AMOUNT
             CALL "CRAFT-STACK-TEXT" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH WS-AMOUNT WS-ITEM
                 WS-TEXT WS-LENGTH
             STRING WS-TEXT(1:WS-LENGTH) DELIMITED BY SIZE INTO WS-LINE WITH POINTER WS-P
         END-PERFORM
         COMPUTE WS-LINE-LENGTH = WS-P - 1
         MOVE 280 TO WS-W
         CALL "WIDGET-ADD" USING CLIENT-STATE WS-LABEL WS-NONE WS-ZERO WS-X0 WS-Y WS-W WS-H
             WS-LINE WS-LINE-LENGTH WS-Z1
*>       The result and the mark under them.
         MOVE "cobolcraft.screen.crafting.result" TO WS-KEY
         MOVE 33 TO WS-KEY-LENGTH
         CALL "CRAFT-STACK-TEXT" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH RB-RES-AMOUNT(WS-R)
             RB-RES-ITEM(WS-R) WS-TEXT WS-LENGTH
         COMPUTE WS-Y = WS-Y + 10
         MOVE 150 TO WS-W
         CALL "WIDGET-ADD" USING CLIENT-STATE WS-LABEL WS-NONE WS-ZERO WS-X0 WS-Y WS-W WS-H
             WS-TEXT WS-LENGTH WS-Z1
         MOVE 2 TO WS-STATE
         MOVE "cobolcraft.screen.crafting.not_craftable" TO WS-KEY
         MOVE 40 TO WS-KEY-LENGTH
         IF RB-CRAFTABLE(WS-R) = 1
             MOVE 0 TO WS-STATE
             MOVE "cobolcraft.screen.crafting.craftable" TO WS-KEY
             MOVE 36 TO WS-KEY-LENGTH
         END-IF
         COMPUTE WS-X = WS-X0 + 150
         MOVE 130 TO WS-W
         CALL "WIDGET-ADD-KEY" USING CLIENT-STATE WS-LABEL WS-NONE WS-X WS-Y WS-W WS-H WS-KEY
             WS-KEY-LENGTH
*>       The Craft control, its argument the display id.
         MOVE "cobolcraft.screen.crafting.craft" TO WS-KEY
         MOVE 32 TO WS-KEY-LENGTH
         CALL "LANG-GET" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH WS-TEXT WS-LENGTH
         COMPUTE WS-X = WS-X0 + 285
         COMPUTE WS-Y = WS-Y - 10
         CALL "WIDGET-ADD" USING CLIENT-STATE WS-BUTTON WS-CRAFT RB-ID(WS-R) WS-X WS-Y WS-BW
             WS-BH WS-TEXT WS-LENGTH WS-STATE
     END-PERFORM
     GOBACK.
 END PROGRAM CRAFTING-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CRAFT-STACK-TEXT.
*> USING CLIENT-STATE, lang key (PIC X(80)) with the arguments count and item name, key length,
*> count, item id, text out (PIC X(512)), length out. An item id outside the registry is named as
*> item 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CLARGS.
 01 WS-ITEM                BINARY-LONG.
 01 WS-EDIT                PIC Z(9)9.
 01 WS-NAME-KEY            PIC X(80).
 01 WS-NAME-KEY-LENGTH     BINARY-LONG.
 01 WS-NAME                PIC X(512).
 01 WS-NAME-LENGTH         BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-KEY                  PIC X(80).
 01 L-KEY-LENGTH           BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-TEXT                 PIC X(512).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-KEY L-KEY-LENGTH L-COUNT L-ITEM L-TEXT L-LENGTH.
     MOVE L-ITEM TO WS-ITEM
     IF WS-ITEM < 0 OR WS-ITEM >= CL-ITEM-COUNT
         MOVE 0 TO WS-ITEM
     END-IF
     MOVE SPACES TO WS-NAME-KEY
     IF CL-IT-STATE(WS-ITEM + 1) > 0
         STRING "block.cobolcraft." FUNCTION TRIM(CL-IT-KEY(WS-ITEM + 1)) DELIMITED BY SIZE
             INTO WS-NAME-KEY
     ELSE
         STRING "item.cobolcraft." FUNCTION TRIM(CL-IT-KEY(WS-ITEM + 1)) DELIMITED BY SIZE
             INTO WS-NAME-KEY
     END-IF
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-NAME-KEY)) TO WS-NAME-KEY-LENGTH
     CALL "LANG-GET" USING CLIENT-STATE WS-NAME-KEY WS-NAME-KEY-LENGTH WS-NAME WS-NAME-LENGTH
     MOVE 2 TO LA-COUNT
     MOVE L-COUNT TO WS-EDIT
     MOVE FUNCTION TRIM(WS-EDIT) TO LA-TEXT(1)
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-EDIT)) TO LA-LENGTH(1)
     MOVE WS-NAME(1:256) TO LA-TEXT(2)
     MOVE FUNCTION MIN(WS-NAME-LENGTH, 256) TO LA-LENGTH(2)
     CALL "LANG-FORMAT" USING CLIENT-STATE L-KEY L-KEY-LENGTH LANG-ARGS L-TEXT L-LENGTH
     GOBACK.
 END PROGRAM CRAFT-STACK-TEXT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CRAFTING-CRAFT.
*> USING CLIENT-STATE, recipe display id: Place Recipe on the game connection.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY PROTO.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-CONN                BINARY-LONG VALUE CONN-GAME.
 01 WS-RECIPE              BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-RECIPE               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-RECIPE.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     MOVE L-RECIPE TO WS-RECIPE
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CLP-PLACE-RECIPE" USING PB-BUFFER WS-RECIPE
     CALL "NET-SEND" USING CLIENT-STATE WS-CONN PB-BUFFER
     GOBACK.
 END PROGRAM CRAFTING-CRAFT.
