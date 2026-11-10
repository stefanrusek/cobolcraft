*> The small recipe book packets of the play state (docs/protocol/27-recipes-and-unlocks.md section 4.4 and 4.7; 05a 0x40; 05c 0x2F
*> and 0x30; T3655 to T3657): Recipe Book Seen, Recipe Book Change Settings and the Place Ghost Recipe answer of Place Recipe.
*> Place Recipe itself is RECIPE-PLACE of recipe-unlock.cob; the book's state is RECBOOK.cpy.
*>
*> Entry points:
*>   RECIPE-SEEN USING connection id, PLAY-SERVERBOUND      Recipe Book Seen (0x30): the recipe of the display id is no longer
*>                                                          highlighted as unseen (an unknown display id changes nothing)
*>   RECIPE-SETTINGS USING connection id, PLAY-SERVERBOUND  Recipe Book Change Settings (0x2F): the book type's open and
*>                                                          filtering flags (a book type outside 0 to 3 is ignored at decode)
*>   RECIPE-GHOST USING connection id, container id, recipe row, display index   Place Ghost Recipe (0x40): the container id
*>                                                          and the recipe's display (27 4.7), sent when Place Recipe could
*>                                                          not fill the grid; nothing is sent for a recipe family the book
*>                                                          has no display for

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RECIPE-SEEN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-ROW                 BINARY-LONG.
 01 WS-RC                  BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 LINKAGE SECTION.
 COPY PLAYPKT.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ID PLAY-SERVERBOUND.
     MOVE CN-PLAYER(L-ID) TO WS-ROW
     CALL "RECIPE-DISPLAY-ROW" USING PSB-RECIPE WS-RC WS-INDEX
     IF WS-ROW > 0 AND WS-RC > 0
         CALL "RECBOOK-SEEN" USING WS-ROW WS-RC
     END-IF
     GOBACK.
 END PROGRAM RECIPE-SEEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RECIPE-SETTINGS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 COPY PLAYPKT.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ID PLAY-SERVERBOUND.
     MOVE CN-PLAYER(L-ID) TO WS-ROW
     IF WS-ROW > 0
         CALL "RECBOOK-SETTING" USING WS-ROW PSB-BOOK-TYPE PSB-BOOK-OPEN PSB-BOOK-FILTER
     END-IF
     GOBACK.
 END PROGRAM RECIPE-SETTINGS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RECIPE-GHOST.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-PACKET-ID           BINARY-LONG VALUE 64.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WS-FLAGS               BINARY-LONG VALUE 0.
 01 WS-BUILT               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-CONTAINER            BINARY-LONG.
 01 L-RECIPE               BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-CONTAINER L-RECIPE L-INDEX.
     CALL "RECIPE-ENTRY-BUILD" USING L-RECIPE L-INDEX WS-FLAGS PB-RECIPE-ENTRY PB-SLOT-DISPLAY-TABLE WS-BUILT
     IF WS-BUILT = 1
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
         CALL "PB-PUT-PLACE-GHOST-RECIPE" USING PB-BUFFER L-CONTAINER PB-RECIPE-ENTRY PB-SLOT-DISPLAY-TABLE
         CALL "CORE-SEND" USING L-ID PB-BUFFER
         CALL "PB-FREE" USING PB-BUFFER
     END-IF
     GOBACK.
 END PROGRAM RECIPE-GHOST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RECIPE-NEW-ITEM.
*> USING player row, new out (1 or 0): 1 when a slot of the player's inventory holds an item that no slot held in the inventory the
*> last unlock check ran over (RB-INVENTORY). The unlock criteria are "an inventory slot holds one of these items" (27 5.9;
*> RECIPE-PREDICATES-HOLD), so only an item that was not held before can make a recipe newly known: a change of counts, or
*> an item that moves between slots, needs no scan of the recipe store (CRAFT-REFRESH-ALL).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY RECBOOK.
 01 WS-SNAPSHOT.
    05 WS-OLD-SLOT OCCURS 36 TIMES.
       10 WS-OLD-ITEM      BINARY-LONG.
       10 WS-OLD-COUNT     BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-HELD                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-NEW.
     MOVE 0 TO L-NEW
     MOVE RB-INVENTORY(L-ROW) TO WS-SNAPSHOT
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 36 OR L-NEW = 1
         IF PL-SLOT-COUNT(L-ROW, WS-S) > 0
             MOVE 0 TO WS-HELD
             PERFORM VARYING WS-T FROM 1 BY 1 UNTIL WS-T > 36 OR WS-HELD = 1
                 IF WS-OLD-COUNT(WS-T) > 0 AND WS-OLD-ITEM(WS-T) = PL-SLOT-ITEM(L-ROW, WS-S)
                     MOVE 1 TO WS-HELD
                 END-IF
             END-PERFORM
             IF WS-HELD = 0
                 MOVE 1 TO L-NEW
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM RECIPE-NEW-ITEM.
