*> The menu stacks of the inventory screen and the bench screen (12 section 5.6a, 5.6b; 13 section 3.5). A screen slot widget's argument
*> names its stack: 0 to 35 the player's slots (hotbar 0 to 8, then the main inventory), 36 the stack on the cursor, 37 the off hand,
*> 100 + n the menu's extra slots n = 1 to 16 (IX of the inventory menu, BX of the bench: n 1 to 4 armour head to feet, 5 the crafting
*> result, 6 to 9 or 6 to 14 the grid). MENU-STACK-GET and MENU-STACK-PUT read and write that stack; MENU-SLOT-WIRE gives the slot's
*> number in the menu of the open screen (what Container Click carries): the inventory menu is 0 result, 1 to 4 grid, 5 to 8 armour,
*> 9 to 35 main, 36 to 44 hotbar, 45 off hand; the bench menu is 0 result, 1 to 9 grid, 10 to 36 main, 37 to 45 hotbar.
*> MENU-SET writes a stack received for a menu slot of a container: container 0 is the inventory menu, the bench's own id the bench;
*> any other container is not shown and changes nothing. STACK-DAMAGE reads the damage component (3) of an item stack.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-SLOT-WIRE.
*> USING CLIENT-STATE, widget argument, menu slot out (-1: the argument is no slot of a menu).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ARG                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ARG L-SLOT.
     MOVE -1 TO L-SLOT
     EVALUATE TRUE
         WHEN L-ARG >= 0 AND L-ARG <= 8
             IF SM-SCREEN = SCR-BENCH
                 COMPUTE L-SLOT = 37 + L-ARG
             ELSE
                 COMPUTE L-SLOT = 36 + L-ARG
             END-IF
         WHEN L-ARG >= 9 AND L-ARG <= 35
             IF SM-SCREEN = SCR-BENCH
                 COMPUTE L-SLOT = L-ARG + 1
             ELSE
                 MOVE L-ARG TO L-SLOT
             END-IF
         WHEN L-ARG = 37
             MOVE 45 TO L-SLOT
         WHEN L-ARG = 105
             MOVE 0 TO L-SLOT
         WHEN L-ARG >= 106 AND L-ARG <= 114
             COMPUTE L-SLOT = L-ARG - 105
         WHEN L-ARG >= 101 AND L-ARG <= 104 AND SM-SCREEN NOT = SCR-BENCH
             COMPUTE L-SLOT = L-ARG - 96
     END-EVALUATE
     GOBACK.
 END PROGRAM MENU-SLOT-WIRE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-STACK-GET.
*> USING CLIENT-STATE, widget argument, count out, item out, damage out (0 for an argument with no stack).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-N                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ARG                  BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-DAMAGE               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ARG L-COUNT L-ITEM L-DAMAGE.
     MOVE 0 TO L-COUNT L-ITEM L-DAMAGE
     EVALUATE TRUE
         WHEN L-ARG >= 0 AND L-ARG <= 35
             MOVE PL-SLOT-COUNT(L-ARG + 1) TO L-COUNT
             MOVE PL-SLOT-ITEM(L-ARG + 1) TO L-ITEM
             MOVE PL-SLOT-DAMAGE(L-ARG + 1) TO L-DAMAGE
         WHEN L-ARG = 36
             MOVE PL-CARRIED-COUNT TO L-COUNT
             MOVE PL-CARRIED-ITEM TO L-ITEM
         WHEN L-ARG = 37
             MOVE PL-OFFHAND-COUNT TO L-COUNT
             MOVE PL-OFFHAND-ITEM TO L-ITEM
             MOVE PL-OFFHAND-DAMAGE TO L-DAMAGE
         WHEN L-ARG >= 101 AND L-ARG <= 116
             COMPUTE WS-N = L-ARG - 100
             IF SM-SCREEN = SCR-BENCH
                 MOVE BX-COUNT(WS-N) TO L-COUNT
                 MOVE BX-ITEM(WS-N) TO L-ITEM
                 MOVE BX-DAMAGE(WS-N) TO L-DAMAGE
             ELSE
                 MOVE IX-COUNT(WS-N) TO L-COUNT
                 MOVE IX-ITEM(WS-N) TO L-ITEM
                 MOVE IX-DAMAGE(WS-N) TO L-DAMAGE
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM MENU-STACK-GET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-STACK-PUT.
*> USING CLIENT-STATE, widget argument, count, item, damage: an argument with no stack changes nothing; a count of 0 or less
*> empties the stack (item and damage 0).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-N                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-DAMAGE              BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ARG                  BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-DAMAGE               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ARG L-COUNT L-ITEM L-DAMAGE.
     MOVE L-COUNT TO WS-COUNT
     MOVE L-ITEM TO WS-ITEM
     MOVE L-DAMAGE TO WS-DAMAGE
     IF WS-COUNT <= 0
         MOVE 0 TO WS-COUNT WS-ITEM WS-DAMAGE
     END-IF
     EVALUATE TRUE
         WHEN L-ARG >= 0 AND L-ARG <= 35
             MOVE WS-COUNT TO PL-SLOT-COUNT(L-ARG + 1)
             MOVE WS-ITEM TO PL-SLOT-ITEM(L-ARG + 1)
             MOVE WS-DAMAGE TO PL-SLOT-DAMAGE(L-ARG + 1)
         WHEN L-ARG = 36
             MOVE WS-COUNT TO PL-CARRIED-COUNT
             MOVE WS-ITEM TO PL-CARRIED-ITEM
         WHEN L-ARG = 37
             MOVE WS-COUNT TO PL-OFFHAND-COUNT
             MOVE WS-ITEM TO PL-OFFHAND-ITEM
             MOVE WS-DAMAGE TO PL-OFFHAND-DAMAGE
         WHEN L-ARG >= 101 AND L-ARG <= 116
             COMPUTE WS-N = L-ARG - 100
             IF SM-SCREEN = SCR-BENCH
                 MOVE WS-COUNT TO BX-COUNT(WS-N)
                 MOVE WS-ITEM TO BX-ITEM(WS-N)
                 MOVE WS-DAMAGE TO BX-DAMAGE(WS-N)
             ELSE
                 MOVE WS-COUNT TO IX-COUNT(WS-N)
                 MOVE WS-ITEM TO IX-ITEM(WS-N)
                 MOVE WS-DAMAGE TO IX-DAMAGE(WS-N)
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM MENU-STACK-PUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-SET.
*> USING CLIENT-STATE, container id, menu slot, count, item, damage: the stack of that menu slot of the container (above); the
*> player's slots a menu shows are the replica's own, so both menus write them.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ARG                 BINARY-LONG.
 01 WS-BENCH               BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-CONTAINER            BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-DAMAGE               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-CONTAINER L-SLOT L-COUNT L-ITEM L-DAMAGE.
     MOVE -1 TO WS-ARG
     MOVE 0 TO WS-BENCH
     IF L-CONTAINER > 0 AND L-CONTAINER = BM-ID
         MOVE 1 TO WS-BENCH
     END-IF
     IF L-CONTAINER = 0
         EVALUATE TRUE
             WHEN L-SLOT = 0
                 MOVE 105 TO WS-ARG
             WHEN L-SLOT >= 1 AND L-SLOT <= 4
                 COMPUTE WS-ARG = 105 + L-SLOT
             WHEN L-SLOT >= 5 AND L-SLOT <= 8
                 COMPUTE WS-ARG = 96 + L-SLOT
             WHEN L-SLOT >= 9 AND L-SLOT <= 35
                 MOVE L-SLOT TO WS-ARG
             WHEN L-SLOT >= 36 AND L-SLOT <= 44
                 COMPUTE WS-ARG = L-SLOT - 36
             WHEN L-SLOT = 45
                 MOVE 37 TO WS-ARG
         END-EVALUATE
     END-IF
     IF WS-BENCH = 1
         EVALUATE TRUE
             WHEN L-SLOT = 0
                 MOVE 105 TO WS-ARG
             WHEN L-SLOT >= 1 AND L-SLOT <= 9
                 COMPUTE WS-ARG = 105 + L-SLOT
             WHEN L-SLOT >= 10 AND L-SLOT <= 36
                 COMPUTE WS-ARG = L-SLOT - 1
             WHEN L-SLOT >= 37 AND L-SLOT <= 45
                 COMPUTE WS-ARG = L-SLOT - 37
         END-EVALUATE
     END-IF
     IF WS-ARG >= 0
         IF WS-BENCH = 1 AND WS-ARG >= 101
             PERFORM SET-BENCH-EXTRA
         ELSE
             IF WS-ARG >= 101
                 PERFORM SET-INVENTORY-EXTRA
             ELSE
                 CALL "MENU-PLAYER-SET" USING CLIENT-STATE WS-ARG L-COUNT L-ITEM L-DAMAGE
             END-IF
         END-IF
     END-IF
     GOBACK.
 SET-BENCH-EXTRA.
     MOVE L-COUNT TO BX-COUNT(WS-ARG - 100)
     MOVE L-ITEM TO BX-ITEM(WS-ARG - 100)
     MOVE L-DAMAGE TO BX-DAMAGE(WS-ARG - 100)
     IF L-COUNT <= 0
         MOVE 0 TO BX-COUNT(WS-ARG - 100) BX-ITEM(WS-ARG - 100) BX-DAMAGE(WS-ARG - 100)
     END-IF
     .
 SET-INVENTORY-EXTRA.
     MOVE L-COUNT TO IX-COUNT(WS-ARG - 100)
     MOVE L-ITEM TO IX-ITEM(WS-ARG - 100)
     MOVE L-DAMAGE TO IX-DAMAGE(WS-ARG - 100)
     IF L-COUNT <= 0
         MOVE 0 TO IX-COUNT(WS-ARG - 100) IX-ITEM(WS-ARG - 100) IX-DAMAGE(WS-ARG - 100)
     END-IF
     .
 END PROGRAM MENU-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-PLAYER-SET.
*> USING CLIENT-STATE, argument 0 to 37 (36 not used), count, item, damage: a player slot or the off hand, whatever screen is open.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ARG                  BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-DAMAGE               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ARG L-COUNT L-ITEM L-DAMAGE.
     IF L-ARG >= 0 AND L-ARG <= 35
         MOVE L-COUNT TO PL-SLOT-COUNT(L-ARG + 1)
         MOVE L-ITEM TO PL-SLOT-ITEM(L-ARG + 1)
         MOVE L-DAMAGE TO PL-SLOT-DAMAGE(L-ARG + 1)
         IF L-COUNT <= 0
             MOVE 0 TO PL-SLOT-COUNT(L-ARG + 1) PL-SLOT-ITEM(L-ARG + 1) PL-SLOT-DAMAGE(L-ARG + 1)
         END-IF
     END-IF
     IF L-ARG = 37
         MOVE L-COUNT TO PL-OFFHAND-COUNT
         MOVE L-ITEM TO PL-OFFHAND-ITEM
         MOVE L-DAMAGE TO PL-OFFHAND-DAMAGE
         IF L-COUNT <= 0
             MOVE 0 TO PL-OFFHAND-COUNT PL-OFFHAND-ITEM PL-OFFHAND-DAMAGE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM MENU-PLAYER-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STACK-DAMAGE.
*> USING PB-ITEMSTACK-X, damage out: the VarInt value of the added component 3 (damage), else 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-BYTE                BINARY-LONG.
 01 WS-SHIFT               BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-DAMAGE               BINARY-LONG.
 PROCEDURE DIVISION USING PB-ITEMSTACK-X L-DAMAGE.
     MOVE 0 TO L-DAMAGE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PB-ISX-ADDED-COUNT
         IF PB-ISX-TYPE(WS-I) = 3
             MOVE 1 TO WS-SHIFT
             MOVE 0 TO WS-DONE
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > PB-ISX-VALUE-LENGTH(WS-I) OR WS-K > 4 OR WS-DONE = 1
                 COMPUTE WS-BYTE = FUNCTION ORD(PB-ISX-VALUE(WS-I)(WS-K:1)) - 1
                 COMPUTE L-DAMAGE = L-DAMAGE + FUNCTION MOD(WS-BYTE, 128) * WS-SHIFT
                 COMPUTE WS-SHIFT = WS-SHIFT * 128
                 IF WS-BYTE < 128
                     MOVE 1 TO WS-DONE
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM STACK-DAMAGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-CONTAINER.
*> USING CLIENT-STATE, container id out, state id out: of the menu the open screen shows (the inventory menu 0, or the bench's).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-CONTAINER            BINARY-LONG.
 01 L-STATE-ID             BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-CONTAINER L-STATE-ID.
     MOVE 0 TO L-CONTAINER
     MOVE PL-INV-STATE-ID TO L-STATE-ID
     IF SM-SCREEN = SCR-BENCH
         MOVE BM-ID TO L-CONTAINER
         MOVE BM-STATE-ID TO L-STATE-ID
     END-IF
     GOBACK.
 END PROGRAM MENU-CONTAINER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ITEM-MAX-STACK.
*> USING item id, maximum stack out: the content library's max_stack_size of the item when the content is open and has it, else the
*> client's table of the built-in items (CL-IT-MAX) for an id it lists, else 64.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-NAME                PIC X(32) VALUE "max_stack_size".
 01 WS-VALUE               PIC X(100).
 01 WS-STATUS              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ITEM                 BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ITEM L-MAX.
     MOVE 64 TO L-MAX
     IF L-ITEM >= 0 AND L-ITEM < CL-ITEM-COUNT
         MOVE CL-IT-MAX(L-ITEM + 1) TO L-MAX
     END-IF
     CALL "CONTENT-ITEM-COMPONENT" USING L-ITEM WS-NAME WS-VALUE WS-STATUS
     IF WS-STATUS = 0 AND WS-VALUE NOT = SPACES
         COMPUTE L-MAX = FUNCTION NUMVAL(WS-VALUE)
     END-IF
     IF L-MAX < 1
         MOVE 64 TO L-MAX
     END-IF
     GOBACK.
 END PROGRAM ITEM-MAX-STACK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STACK-NOTE-MAX.
*> USING CLIENT-STATE, PB-ITEMSTACK-X: when the stack's patch adds the max_damage component (2, a VarInt), the item's maximum is
*> remembered (MX-ENTRY, the newest of 16 items; the item's content gives it when no stack has said).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-BYTE                BINARY-LONG.
 01 WS-SHIFT               BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-AT                  BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 COPY PROTO.
 PROCEDURE DIVISION USING CLIENT-STATE PB-ITEMSTACK-X.
     IF PB-ISX-COUNT > 0
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PB-ISX-ADDED-COUNT
             IF PB-ISX-TYPE(WS-I) = 2
                 MOVE 0 TO WS-MAX
                 MOVE 1 TO WS-SHIFT
                 MOVE 0 TO WS-DONE
                 PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > PB-ISX-VALUE-LENGTH(WS-I) OR WS-K > 4 OR WS-DONE = 1
                     COMPUTE WS-BYTE = FUNCTION ORD(PB-ISX-VALUE(WS-I)(WS-K:1)) - 1
                     COMPUTE WS-MAX = WS-MAX + FUNCTION MOD(WS-BYTE, 128) * WS-SHIFT
                     COMPUTE WS-SHIFT = WS-SHIFT * 128
                     IF WS-BYTE < 128
                         MOVE 1 TO WS-DONE
                     END-IF
                 END-PERFORM
                 MOVE 0 TO WS-AT
                 PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > MX-COUNT
                     IF MX-ITEM(WS-K) = PB-ISX-ITEM
                         MOVE WS-K TO WS-AT
                     END-IF
                 END-PERFORM
                 IF WS-AT = 0 AND MX-COUNT < 16
                     ADD 1 TO MX-COUNT
                     MOVE MX-COUNT TO WS-AT
                 END-IF
                 IF WS-AT = 0
                     MOVE 16 TO WS-AT
                 END-IF
                 MOVE PB-ISX-ITEM TO MX-ITEM(WS-AT)
                 MOVE WS-MAX TO MX-MAX(WS-AT)
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM STACK-NOTE-MAX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ITEM-MAX-DAMAGE.
*> USING CLIENT-STATE, item id, maximum damage out (0: the item is not damageable as far as the client knows): what a stack's patch said
*> (MX-ENTRY), else the content library's max_damage of the item.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-K                   BINARY-LONG.
 01 WS-NAME                PIC X(32) VALUE "max_damage".
 01 WS-VALUE               PIC X(100).
 01 WS-STATUS              BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ITEM                 BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ITEM L-MAX.
     MOVE 0 TO L-MAX
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > MX-COUNT
         IF MX-ITEM(WS-K) = L-ITEM
             MOVE MX-MAX(WS-K) TO L-MAX
         END-IF
     END-PERFORM
     IF L-MAX = 0
         CALL "CONTENT-ITEM-COMPONENT" USING L-ITEM WS-NAME WS-VALUE WS-STATUS
         IF WS-STATUS = 0 AND WS-VALUE NOT = SPACES
             COMPUTE L-MAX = FUNCTION NUMVAL(WS-VALUE)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM ITEM-MAX-DAMAGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ITEM-BAR.
*> USING damage, maximum damage, width out, swatch out (17 §5.7 itemBar): for a damaged stack (damage > 0, maximum > 0) the bar is
*> clamp(round(13 - damage x 13 / maximum), 0, 13) pixels wide, in the swatch SW-BAR-0 + round(23 x (maximum - damage) / maximum)
*> (hue (maximum - damage) / maximum / 3: red worn, green new); width -1 for no bar.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-W                   BINARY-LONG.
 01 WS-F                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-DAMAGE               BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 01 L-WIDTH                BINARY-LONG.
 01 L-SWATCH               BINARY-LONG.
 PROCEDURE DIVISION USING L-DAMAGE L-MAX L-WIDTH L-SWATCH.
     MOVE -1 TO L-WIDTH
     MOVE SW-BAR-0 TO L-SWATCH
     IF L-DAMAGE > 0 AND L-MAX > 0
         COMPUTE WS-F = (L-MAX - L-DAMAGE) / L-MAX
         IF WS-F < 0
             MOVE 0 TO WS-F
         END-IF
         COMPUTE WS-W ROUNDED = 13 - L-DAMAGE * 13 / L-MAX
         MOVE FUNCTION MAX(0, FUNCTION MIN(13, WS-W)) TO L-WIDTH
         COMPUTE L-SWATCH ROUNDED = SW-BAR-0 + 23 * WS-F
     END-IF
     GOBACK.
 END PROGRAM ITEM-BAR.
