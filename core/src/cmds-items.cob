*> The commands of items and inventory (docs/protocol/16-commands-catalog.md §6): give, clear. A CX- program reads its parsed context through
*> the BX- helpers, tells through BR-FEEDBACK, sets BR-R-RESULT and, to fail, raises an exception (BR-RAISE) and sets BR-R-FAILED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-GIVE.
*> give <targets> <item> [<count>] (16 §6.1, level 2): the count (1 by default, at most 100 stacks of the item) goes into each target's
*> inventory (INV-ADD) in stacks of at most the maximum stack size and what does not fit is dropped at the player as ground items
*> with no pickup delay; the player is sent the inventory; commands.give.success.single [count, item key, player] or .multiple
*> [count, item key, number of players] is broadcast; more than 100 stacks is commands.give.failed.toomanyitems [maximum, item key];
*> the result is the total given. An item with components is refused (BLOCKED: no component patch from a command).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 COPY BRRUN.
 COPY PROTO.
 01 WS-NAME-TARGETS        PIC X(32) VALUE "targets".
 01 WS-NAME-ITEM           PIC X(32) VALUE "item".
 01 WS-NAME-COUNT          PIC X(32) VALUE "count".
 01 WS-ROWS.
    05 BX-COUNT             BINARY-LONG.
    05 BX-ROW               BINARY-LONG OCCURS 64 TIMES.
 01 WS-INDEX               BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-MAX-STACK           BINARY-LONG.
 01 WS-LIMIT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 01 WS-PART                BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-DELAY               BINARY-LONG VALUE 0.
 01 WS-Y                   FLOAT-LONG.
 01 WS-ZERO-VELOCITY       FLOAT-LONG VALUE 0.
 01 WS-ZERO-Y              FLOAT-LONG VALUE 0.
 01 WS-ZERO-Z              FLOAT-LONG VALUE 0.
 01 WS-KEY                 PIC X(72).
 01 WS-BROADCAST           BINARY-LONG VALUE 1.
 01 WS-A1                  PIC X(64).
 01 WS-A2                  PIC X(64).
 01 WS-N-ARGS              BINARY-LONG.
 01 WS-L1                  BINARY-LONG.
 01 WS-L2                  BINARY-LONG.
 01 WS-RC                  BINARY-LONG VALUE -1.
 01 WS-EDIT                PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "BX-FIND" USING WS-NAME-TARGETS WS-INDEX
     CALL "BX-RESOLVE" USING WS-INDEX WS-ROWS
     IF BR-R-FAILED = 0
         CALL "BX-FIND" USING WS-NAME-ITEM WS-INDEX
         MOVE BA-IVAL(WS-INDEX) TO WS-ITEM
         IF BA-AUX(WS-INDEX) >= 2
             MOVE "cobolcraft.item.components_unsupported" TO WS-KEY
             MOVE 0 TO WS-N-ARGS WS-L1 WS-L2
             CALL "BR-RAISE" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2 WS-RC
             MOVE 1 TO BR-R-FAILED
         END-IF
     END-IF
     IF BR-R-FAILED = 0
         MOVE 1 TO WS-COUNT
         CALL "BX-FIND" USING WS-NAME-COUNT WS-INDEX
         IF WS-INDEX > 0
             MOVE BA-IVAL(WS-INDEX) TO WS-COUNT
         END-IF
         MOVE IT-MAX-STACK(WS-ITEM + 1) TO WS-MAX-STACK
         COMPUTE WS-LIMIT = WS-MAX-STACK * 100
         IF WS-COUNT > WS-LIMIT
             MOVE "commands.give.failed.toomanyitems" TO WS-KEY
             MOVE SPACES TO WS-A1 WS-A2
             MOVE WS-LIMIT TO WS-EDIT
             MOVE FUNCTION TRIM(WS-EDIT) TO WS-A1
             MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-EDIT)) TO WS-L1
             MOVE IT-KEY(WS-ITEM + 1) TO WS-A2
             MOVE IT-KEY-LENGTH(WS-ITEM + 1) TO WS-L2
             MOVE 2 TO WS-N-ARGS
             CALL "BR-RAISE" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2 WS-RC
             MOVE 1 TO BR-R-FAILED
         END-IF
     END-IF
     IF BR-R-FAILED = 0
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BX-COUNT
             MOVE BX-ROW(WS-I) TO WS-ROW
             CALL "INV-ADD" USING WS-ROW WS-ITEM WS-COUNT WS-LEFT
             PERFORM UNTIL WS-LEFT = 0
                 MOVE WS-LEFT TO WS-PART
                 IF WS-PART > WS-MAX-STACK
                     MOVE WS-MAX-STACK TO WS-PART
                 END-IF
                 MOVE PL-Y(WS-ROW) TO WS-Y
                 CALL "GI-SPAWN" USING PL-DIM(WS-ROW) PL-X(WS-ROW) WS-Y PL-Z(WS-ROW) WS-ZERO-VELOCITY WS-ZERO-Y
                     WS-ZERO-Z WS-ITEM WS-PART WS-DELAY WS-NEW
                 SUBTRACT WS-PART FROM WS-LEFT
             END-PERFORM
             CALL "CMD-SEND-INVENTORY" USING WS-ROW
         END-PERFORM
         IF BX-COUNT = 1
             MOVE "commands.give.success.single" TO WS-KEY
         ELSE
             MOVE "commands.give.success.multiple" TO WS-KEY
         END-IF
         CALL "BX-KEY" USING PB-TEXT WS-KEY
         CALL "CMD-TEXT-INT" USING PB-TEXT WS-COUNT
         CALL "CMD-TEXT-ARG" USING PB-TEXT IT-KEY(WS-ITEM + 1) IT-KEY-LENGTH(WS-ITEM + 1)
         IF BX-COUNT = 1
             CALL "CMD-TEXT-ARG" USING PB-TEXT PL-NAME(BX-ROW(1)) PL-NAME-LENGTH(BX-ROW(1))
         ELSE
             CALL "CMD-TEXT-INT" USING PB-TEXT BX-COUNT
         END-IF
         CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST
         COMPUTE BR-R-RESULT = WS-COUNT * BX-COUNT
     END-IF
     GOBACK.
 END PROGRAM CX-GIVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-GIVE.
*> The forms of give (16 §6.1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 2.
 01 WS-COMMAND             BINARY-LONG VALUE BC-GIVE.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     MOVE "give <targets:players> <item:item>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "give <targets:players> <item:item> <count:int:1>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     GOBACK.
 END PROGRAM CMDS-REG-GIVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-CLEAR.
*> clear [<targets> [<item> [<maxCount>]]] (16 §6.2, level 2): the matching items of each target's inventory (the 36 slots and the
*> cursor), all of them or at most maxCount (0 only counts); the player is sent the inventory; commands.clear.success.single [count,
*> player] or .multiple [count, number of players] (.test. for maxCount 0), broadcast, when anything was found; nothing found is
*> clear.failed.single [player] or .multiple [number of players]; the result is the number found. The predicate is an item or *;
*> an item tag or conditions are refused (BLOCKED: no item tags and no components to test).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BRRUN.
 COPY PROTO.
 01 WS-NAME-TARGETS        PIC X(32) VALUE "targets".
 01 WS-NAME-ITEM           PIC X(32) VALUE "item".
 01 WS-NAME-MAX            PIC X(32) VALUE "maxCount".
 01 WS-ROWS.
    05 BX-COUNT             BINARY-LONG.
    05 BX-ROW               BINARY-LONG OCCURS 64 TIMES.
 01 WS-INDEX               BINARY-LONG.
 01 WS-ITEM                BINARY-LONG VALUE -1.
 01 WS-MAX                 BINARY-LONG.
 01 WS-LIMITED             BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-TAKE                BINARY-LONG.
 01 WS-ROOM                BINARY-LONG.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-HOLDERS             BINARY-LONG.
 01 WS-LAST-HOLDER         BINARY-LONG.
 01 WS-KEY                 PIC X(72).
 01 WS-BROADCAST           BINARY-LONG VALUE 1.
 01 WS-A1                  PIC X(64).
 01 WS-A2                  PIC X(64).
 01 WS-N-ARGS              BINARY-LONG.
 01 WS-L1                  BINARY-LONG.
 01 WS-L2                  BINARY-LONG.
 01 WS-RC                  BINARY-LONG VALUE -1.
 PROCEDURE DIVISION.
     MOVE -1 TO WS-ITEM
     CALL "BX-TARGETS-OR-SELF" USING WS-NAME-TARGETS WS-ROWS
     IF BR-R-FAILED = 0
         CALL "BX-FIND" USING WS-NAME-ITEM WS-INDEX
         IF WS-INDEX > 0
             MOVE BA-IVAL(WS-INDEX) TO WS-ITEM
             IF BA-AUX(WS-INDEX) = 1 OR BA-AUX(WS-INDEX) = 2 OR BA-AUX(WS-INDEX) = 3
                 MOVE "cobolcraft.item.predicate_unsupported" TO WS-KEY
                 MOVE 0 TO WS-N-ARGS WS-L1 WS-L2
                 CALL "BR-RAISE" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2 WS-RC
                 MOVE 1 TO BR-R-FAILED
             END-IF
         END-IF
     END-IF
     IF BR-R-FAILED = 0
         MOVE 0 TO WS-LIMITED
         MOVE 0 TO WS-MAX
         CALL "BX-FIND" USING WS-NAME-MAX WS-INDEX
         IF WS-INDEX > 0
             MOVE 1 TO WS-LIMITED
             MOVE BA-IVAL(WS-INDEX) TO WS-MAX
         END-IF
         MOVE 0 TO WS-TOTAL WS-HOLDERS
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BX-COUNT
             MOVE BX-ROW(WS-I) TO WS-ROW
             MOVE 0 TO WS-FOUND
             PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 36
                 IF PL-SLOT-COUNT(WS-ROW, WS-S) > 0 AND (WS-ITEM < 0 OR PL-SLOT-ITEM(WS-ROW, WS-S) = WS-ITEM)
                     MOVE PL-SLOT-COUNT(WS-ROW, WS-S) TO WS-TAKE
                     IF WS-LIMITED = 1 AND WS-MAX > 0
                         COMPUTE WS-ROOM = WS-MAX - WS-FOUND
                         IF WS-TAKE > WS-ROOM
                             MOVE WS-ROOM TO WS-TAKE
                         END-IF
                     END-IF
                     IF WS-LIMITED = 1 AND WS-MAX = 0
                         MOVE PL-SLOT-COUNT(WS-ROW, WS-S) TO WS-TAKE
                     END-IF
                     ADD WS-TAKE TO WS-FOUND
                     IF NOT (WS-LIMITED = 1 AND WS-MAX = 0)
                         SUBTRACT WS-TAKE FROM PL-SLOT-COUNT(WS-ROW, WS-S)
                         IF PL-SLOT-COUNT(WS-ROW, WS-S) = 0
                             MOVE 0 TO PL-SLOT-ITEM(WS-ROW, WS-S)
                         END-IF
                     END-IF
                 END-IF
             END-PERFORM
             IF WS-FOUND > 0
                 ADD WS-FOUND TO WS-TOTAL
                 ADD 1 TO WS-HOLDERS
                 MOVE WS-ROW TO WS-LAST-HOLDER
             END-IF
             IF NOT (WS-LIMITED = 1 AND WS-MAX = 0)
                 CALL "CMD-SEND-INVENTORY" USING WS-ROW
             END-IF
         END-PERFORM
         IF WS-TOTAL = 0
             IF BX-COUNT = 1
                 MOVE "clear.failed.single" TO WS-KEY
                 MOVE 1 TO WS-N-ARGS
                 MOVE SPACES TO WS-A1 WS-A2
                 MOVE PL-NAME(BX-ROW(1)) TO WS-A1
                 MOVE PL-NAME-LENGTH(BX-ROW(1)) TO WS-L1
             ELSE
                 MOVE "clear.failed.multiple" TO WS-KEY
                 MOVE 1 TO WS-N-ARGS
                 MOVE SPACES TO WS-A1 WS-A2
                 MOVE BX-COUNT TO WS-L2
                 CALL "BX-KEY" USING PB-TEXT WS-KEY
                 CALL "CMD-TEXT-INT" USING PB-TEXT BX-COUNT
                 MOVE PB-TX-ARG-VALUE(1) TO WS-A1
                 MOVE PB-TX-ARG-LENGTH(1) TO WS-L1
             END-IF
             MOVE 0 TO WS-L2
             CALL "BR-RAISE" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2 WS-RC
             MOVE 1 TO BR-R-FAILED
         ELSE
             PERFORM TELL-FOUND
             MOVE WS-TOTAL TO BR-R-RESULT
         END-IF
     END-IF
     GOBACK.

*> The message of the found items: success or test (maxCount 0), single when one player held some, else multiple.
 TELL-FOUND.
     IF WS-LIMITED = 1 AND WS-MAX = 0
         IF WS-HOLDERS = 1
             MOVE "commands.clear.test.single" TO WS-KEY
         ELSE
             MOVE "commands.clear.test.multiple" TO WS-KEY
         END-IF
     ELSE
         IF WS-HOLDERS = 1
             MOVE "commands.clear.success.single" TO WS-KEY
         ELSE
             MOVE "commands.clear.success.multiple" TO WS-KEY
         END-IF
     END-IF
     CALL "BX-KEY" USING PB-TEXT WS-KEY
     CALL "CMD-TEXT-INT" USING PB-TEXT WS-TOTAL
     IF WS-HOLDERS = 1
         CALL "CMD-TEXT-ARG" USING PB-TEXT PL-NAME(WS-LAST-HOLDER) PL-NAME-LENGTH(WS-LAST-HOLDER)
     ELSE
         CALL "CMD-TEXT-INT" USING PB-TEXT WS-HOLDERS
     END-IF
     CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST.
 END PROGRAM CX-CLEAR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-CLEAR.
*> The forms of clear (16 §6.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 2.
 01 WS-COMMAND             BINARY-LONG VALUE BC-CLEAR.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     MOVE "clear" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "clear <targets:players>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "clear <targets:players> <item:itempred>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "clear <targets:players> <item:itempred> <maxCount:int:0>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     GOBACK.
 END PROGRAM CMDS-REG-CLEAR.
