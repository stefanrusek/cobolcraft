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
     GO TO MAIN-LINE.

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

 MAIN-LINE.
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

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CXB-RECIPE-GIVE.
*> USING player row, recipe row (0 = every recipe), added out: the recipes added to the book (RECBOOK-ADD: a special recipe is not) and, when any, the
*> Recipe Book Add (0x4B) of them (RECBOOK-SEND).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTRECIPE.
 01 WS-K                   BINARY-LONG.
 01 WS-ONE                 BINARY-LONG.
 01 WS-NO-REPLACE          BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-RECIPE               BINARY-LONG.
 01 L-ADDED                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-RECIPE L-ADDED.
     MOVE 0 TO L-ADDED
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > RC-COUNT
         IF L-RECIPE = 0 OR L-RECIPE = WS-K
             CALL "RECBOOK-ADD" USING L-ROW WS-K WS-ONE
             ADD WS-ONE TO L-ADDED
         END-IF
     END-PERFORM
     IF L-ADDED > 0
         CALL "RECBOOK-SEND" USING L-ROW WS-NO-REPLACE
     END-IF
     GOBACK.
 END PROGRAM CXB-RECIPE-GIVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CXB-RECIPE-TAKE.
*> USING player row, recipe row (0 = every recipe), removed out: the known recipes taken out of the book (RECBOOK-REMOVE) and, when any, one Recipe Book Remove
*> (0x4C) with their display ids.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CTRECIPE.
 COPY RECBOOK.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-PACKET-ID           BINARY-LONG VALUE 76.
 01 WS-K                   BINARY-LONG.
 01 WS-ONE                 BINARY-LONG.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-MARKS.
    05 WS-MARK             PIC 9 OCCURS 4096 TIMES.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-RECIPE               BINARY-LONG.
 01 L-REMOVED              BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-RECIPE L-REMOVED.
     MOVE 0 TO L-REMOVED WS-TOTAL
     INITIALIZE WS-MARKS
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > RC-COUNT
         IF (L-RECIPE = 0 OR L-RECIPE = WS-K) AND RB-KNOWN(L-ROW, WS-K) = 1
             MOVE 1 TO WS-MARK(WS-K)
             ADD 1 TO L-REMOVED
             CALL "RECIPE-DISPLAY-COUNT" USING WS-K WS-N
             ADD WS-N TO WS-TOTAL
         END-IF
     END-PERFORM
     IF L-REMOVED > 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
         CALL "PB-PUT-VARINT" USING PB-BUFFER WS-TOTAL
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > RC-COUNT
             IF WS-MARK(WS-K) = 1
                 CALL "RECIPE-DISPLAY-FIRST" USING WS-K WS-FIRST
                 CALL "RECIPE-DISPLAY-COUNT" USING WS-K WS-N
                 PERFORM VARYING WS-D FROM 0 BY 1 UNTIL WS-D >= WS-N
                     COMPUTE WS-ID = WS-FIRST + WS-D
                     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ID
                 END-PERFORM
                 CALL "RECBOOK-REMOVE" USING L-ROW WS-K WS-ONE
             END-IF
         END-PERFORM
         CALL "CORE-SEND" USING PL-CONN(L-ROW) PB-BUFFER
         CALL "PB-FREE" USING PB-BUFFER
     END-IF
     GOBACK.
 END PROGRAM CXB-RECIPE-TAKE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-RECIPE.
*> recipe give|take <targets> <recipe> | * (16 §6.5, level 2): the recipe (its key with the namespace, or the short name of the cobolcraft set) or every recipe is added
*> to (give: RECBOOK-ADD, the Recipe Book Add sent) or removed from (take: RECBOOK-REMOVE, one Recipe Book Remove sent) the recipe book of each player. A player counts
*> when at least one recipe changed; none counting is commands.recipe.give.failed / .take.failed, else commands.recipe.give|take.success.single [recipes, name] (one player
*> counted) or .multiple [recipes, players counted] is broadcast, the recipes being the number the command names (1 or all); the result is the number of recipes changed.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CTRECIPE.
 COPY BRRUN.
 COPY PROTO.
 01 WS-NAME-TARGETS        PIC X(32) VALUE "targets".
 01 WS-NAME-RECIPE         PIC X(32) VALUE "recipe".
 01 WS-NAME-GIVE           PIC X(32) VALUE "give".
 01 WS-NAME-ALL            PIC X(32) VALUE "*".
 01 WS-ROWS.
    05 BX-COUNT             BINARY-LONG.
    05 BX-ROW               BINARY-LONG OCCURS 64 TIMES.
 01 WS-INDEX               BINARY-LONG.
 01 WS-GIVE                BINARY-LONG.
 01 WS-ALL                 BINARY-LONG.
 01 WS-RECIPE              BINARY-LONG.
 01 WS-SELECTED            BINARY-LONG.
 01 WS-ID                  PIC X(64).
 01 WS-ID-LENGTH           BINARY-LONG.
 01 WS-KEY112              PIC X(112).
 01 WS-I                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-CHANGED             BINARY-LONG.
 01 WS-COUNTED             BINARY-LONG.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-KEY                 PIC X(72).
 01 WS-BROADCAST           BINARY-LONG VALUE 1.
 01 WS-A1                  PIC X(64).
 01 WS-A2                  PIC X(64).
 01 WS-N-ARGS              BINARY-LONG VALUE 0.
 01 WS-L1                  BINARY-LONG VALUE 0.
 01 WS-L2                  BINARY-LONG VALUE 0.
 01 WS-RC                  BINARY-LONG VALUE -1.
 PROCEDURE DIVISION.
     CALL "BX-FIND" USING WS-NAME-TARGETS WS-INDEX
     CALL "BX-RESOLVE" USING WS-INDEX WS-ROWS
     CALL "BX-LIT" USING WS-NAME-GIVE WS-GIVE
     CALL "BX-LIT" USING WS-NAME-ALL WS-ALL
     IF BR-R-FAILED = 0
         MOVE 0 TO WS-RECIPE
         MOVE RC-COUNT TO WS-SELECTED
         IF WS-ALL = 0
             MOVE 1 TO WS-SELECTED
             CALL "BX-FIND" USING WS-NAME-RECIPE WS-INDEX
             CALL "BX-NAMESPACED" USING WS-INDEX WS-ID WS-ID-LENGTH
             MOVE WS-ID TO WS-KEY112
             CALL "RECIPE-BY-KEY" USING WS-KEY112 WS-RECIPE
             IF WS-RECIPE = 0
                 MOVE SPACES TO WS-KEY112
                 STRING "cobolcraft:" WS-ID(11:WS-ID-LENGTH - 10) DELIMITED BY SIZE INTO WS-KEY112
                 CALL "RECIPE-BY-KEY" USING WS-KEY112 WS-RECIPE
             END-IF
             IF WS-RECIPE = 0
                 MOVE "recipe.notFound" TO WS-KEY
                 MOVE SPACES TO WS-A1 WS-A2
                 MOVE WS-ID TO WS-A1
                 MOVE WS-ID-LENGTH TO WS-L1
                 MOVE 1 TO WS-N-ARGS
                 CALL "BR-RAISE" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2 WS-RC
                 MOVE 1 TO BR-R-FAILED
             END-IF
         END-IF
         IF BR-R-FAILED = 0
             MOVE 0 TO WS-COUNTED WS-TOTAL WS-LAST
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BX-COUNT
                 MOVE BX-ROW(WS-I) TO WS-ROW
                 IF WS-GIVE > 0
                     CALL "CXB-RECIPE-GIVE" USING WS-ROW WS-RECIPE WS-CHANGED
                 ELSE
                     CALL "CXB-RECIPE-TAKE" USING WS-ROW WS-RECIPE WS-CHANGED
                 END-IF
                 IF WS-CHANGED > 0
                     ADD 1 TO WS-COUNTED
                     ADD WS-CHANGED TO WS-TOTAL
                     MOVE WS-ROW TO WS-LAST
                 END-IF
             END-PERFORM
             EVALUATE TRUE
                 WHEN WS-COUNTED = 0 AND WS-GIVE > 0
                     MOVE "commands.recipe.give.failed" TO WS-KEY
                 WHEN WS-COUNTED = 0
                     MOVE "commands.recipe.take.failed" TO WS-KEY
                 WHEN WS-GIVE > 0 AND WS-COUNTED = 1
                     MOVE "commands.recipe.give.success.single" TO WS-KEY
                 WHEN WS-GIVE > 0
                     MOVE "commands.recipe.give.success.multiple" TO WS-KEY
                 WHEN WS-COUNTED = 1
                     MOVE "commands.recipe.take.success.single" TO WS-KEY
                 WHEN OTHER
                     MOVE "commands.recipe.take.success.multiple" TO WS-KEY
             END-EVALUATE
             IF WS-COUNTED = 0
                 MOVE SPACES TO WS-A1 WS-A2
                 MOVE 0 TO WS-N-ARGS WS-L1
                 CALL "BR-RAISE" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2 WS-RC
                 MOVE 1 TO BR-R-FAILED
             ELSE
                 CALL "BX-KEY" USING PB-TEXT WS-KEY
                 CALL "CMD-TEXT-INT" USING PB-TEXT WS-SELECTED
                 IF WS-COUNTED = 1
                     CALL "CMD-TEXT-ARG" USING PB-TEXT PL-NAME(WS-LAST) PL-NAME-LENGTH(WS-LAST)
                 ELSE
                     CALL "CMD-TEXT-INT" USING PB-TEXT WS-COUNTED
                 END-IF
                 CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST
                 MOVE WS-TOTAL TO BR-R-RESULT
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM CX-RECIPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-RECIPE.
*> The forms of recipe (16 §6.5).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 2.
 01 WS-COMMAND             BINARY-LONG VALUE BC-RECIPE.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     MOVE "recipe give <targets:players> *" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "recipe give <targets:players> <recipe:recipetype>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "recipe take <targets:players> *" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "recipe take <targets:players> <recipe:recipetype>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     GOBACK.
 END PROGRAM CMDS-REG-RECIPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CXB-ITEM-SLOT.
*> USING player row, slot id (15 §6.6 numbering), index out: the PL-SLOT index of the slot a player owns here (ids 0 to 35 are the hotbar, inventory and container
*> slots; 98, weapon.mainhand, is the held hotbar slot), 0 for any other id and for a row that is not a player.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-INDEX.
     MOVE 0 TO L-INDEX
     EVALUATE TRUE
         WHEN L-ROW <= 0
             CONTINUE
         WHEN L-SLOT >= 0 AND L-SLOT <= 35
             COMPUTE L-INDEX = L-SLOT + 1
         WHEN L-SLOT = 98
             COMPUTE L-INDEX = PL-HELD(L-ROW) + 1
     END-EVALUATE
     GOBACK.
 END PROGRAM CXB-ITEM-SLOT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-ITEM.
*> item replace|fill|override entity|block <holder> <slots> with <item> [<count>] | from entity|block <source> <sourceSlots> [<modifier>] and item modify (16 §6.3, level 2).
*> The source is a list of stacks (with: the one stack; from: the stack of each source slot, empty ones too) laid on the selected slots in order: replace puts them on the
*> first slots and leaves the rest, fill repeats them over every slot, override also empties the slots after them. Each player target takes the slots it owns (CXB-ITEM-SLOT) and
*> is sent the inventory; commands.item.entity.replace.success.single[.known_item] [slots, name (, item)] (one target changed) or .multiple[.known_item] [entities (, item)] is
*> broadcast, known_item for with; the result is the slots set. No target with any slot is commands.item.target.no_such_slot [slot name] (.unnamed for a range), a source
*> without the slot commands.item.source.no_such_slot[.unnamed], a block holder commands.item.target.not_a_container / .source.not_a_container [x, y, z]. Not done: block holders
*> (no live container block exists), the equipment, cursor, crafting and ender chest slots, and item modifiers (any modifier is cobolcraft.item.modifier_unsupported, so
*> modify and the modify messages are unreachable); .target.failed is not reachable (an owned slot always accepts).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 COPY BRRUN.
 COPY PROTO.
 01 WS-NAME-TARGETS        PIC X(32) VALUE "targets".
 01 WS-NAME-POS            PIC X(32) VALUE "pos".
 01 WS-NAME-SLOTS          PIC X(32) VALUE "slots".
 01 WS-NAME-SOURCES        PIC X(32) VALUE "sourceEntities".
 01 WS-NAME-SOURCE-POS     PIC X(32) VALUE "sourcePos".
 01 WS-NAME-SOURCE-SLOTS   PIC X(32) VALUE "sourceSlots".
 01 WS-NAME-MODIFIER       PIC X(32) VALUE "modifier".
 01 WS-NAME-ITEM           PIC X(32) VALUE "item".
 01 WS-NAME-COUNT          PIC X(32) VALUE "count".
 01 WS-NAME-WITH           PIC X(32) VALUE "with".
 01 WS-NAME-FILL           PIC X(32) VALUE "fill".
 01 WS-NAME-OVERRIDE       PIC X(32) VALUE "override".
 01 WS-ROWS.
    05 BX-COUNT             BINARY-LONG.
    05 BX-ROW               BINARY-LONG OCCURS 64 TIMES.
 01 WS-SOURCE-ROWS.
    05 WS-SOURCE-COUNT      BINARY-LONG.
    05 WS-SOURCE-ROW        BINARY-LONG OCCURS 64 TIMES.
 01 WS-INDEX               BINARY-LONG.
 01 WS-MODIFIER            BINARY-LONG.
 01 WS-WITH                BINARY-LONG.
 01 WS-FILL                BINARY-LONG.
 01 WS-OVERRIDE            BINARY-LONG.
 01 WS-TARGET-INDEX        BINARY-LONG.
 01 WS-SLOTS-INDEX         BINARY-LONG.
 01 WS-SLOT-COUNT          BINARY-LONG.
 01 WS-SLOTS.
    05 WS-SLOT              BINARY-LONG OCCURS 64 TIMES.
 01 WS-SRC-COUNT           BINARY-LONG.
 01 WS-SRC-SLOT-COUNT      BINARY-LONG.
 01 WS-SRC-SLOTS.
    05 WS-SRC-SLOT          BINARY-LONG OCCURS 64 TIMES.
 01 WS-STACKS.
    05 WS-STACK OCCURS 64 TIMES.
       10 WS-ST-ITEM        BINARY-LONG.
       10 WS-ST-COUNT       BINARY-LONG.
       10 WS-ST-VAR         BINARY-LONG.
 01 WS-STACK-COUNT         BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-TEXT-LENGTH         BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-AT                  BINARY-LONG.
 01 WS-CHANGED             BINARY-LONG.
 01 WS-TRACKED             BINARY-LONG.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-LAST-CHANGED        BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-KEY                 PIC X(72).
 01 WS-BROADCAST           BINARY-LONG VALUE 1.
 01 WS-A1                  PIC X(64).
 01 WS-A2                  PIC X(64).
 01 WS-A3                  PIC X(64).
 01 WS-N-ARGS              BINARY-LONG.
 01 WS-L1                  BINARY-LONG.
 01 WS-L2                  BINARY-LONG.
 01 WS-L3                  BINARY-LONG.
 01 WS-RC                  BINARY-LONG VALUE -1.
 01 WS-EDIT                PIC -(9)9.
 PROCEDURE DIVISION.
     GO TO MAIN-LINE.

*> The slot argument WS-SLOTS-INDEX read as slot ids in WS-SLOTS (WS-SLOT-COUNT of them) and its text in WS-TEXT.
 READ-SLOTS.
     COMPUTE WS-TEXT-LENGTH = BA-END(WS-SLOTS-INDEX) - BA-START(WS-SLOTS-INDEX)
     MOVE SPACES TO WS-TEXT
     MOVE BR-R-LINE(BA-START(WS-SLOTS-INDEX) + 1:WS-TEXT-LENGTH) TO WS-TEXT
     CALL "BR-SLOT-LOOKUP" USING WS-TEXT WS-TEXT-LENGTH WS-SLOT-COUNT WS-SLOTS.

*> Raises WS-KEY: with the slot text as its argument when the slot argument names one slot, else the key plus ".unnamed" is the caller's.
 RAISE-SLOT.
     MOVE SPACES TO WS-A1 WS-A2
     IF WS-SLOT-COUNT = 1
         MOVE WS-TEXT(1:WS-TEXT-LENGTH) TO WS-A1
         MOVE WS-TEXT-LENGTH TO WS-L1
         MOVE 1 TO WS-N-ARGS
     ELSE
         MOVE 0 TO WS-N-ARGS WS-L1
         STRING FUNCTION TRIM(WS-KEY) ".unnamed" DELIMITED BY SIZE INTO WS-A2
         MOVE WS-A2 TO WS-KEY
         MOVE SPACES TO WS-A2
     END-IF
     CALL "BR-RAISE" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2 WS-RC
     MOVE 1 TO BR-R-FAILED.

*> Raises WS-KEY with the block position of the argument WS-INDEX (the floor of each coordinate).
 RAISE-BLOCK.
     CALL "BX-POSITION" USING WS-INDEX WS-X WS-Y WS-Z
     MOVE SPACES TO WS-A1 WS-A2 WS-A3
     COMPUTE WS-I = FUNCTION INTEGER(WS-X)
     MOVE WS-I TO WS-EDIT
     MOVE FUNCTION TRIM(WS-EDIT) TO WS-A1
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-EDIT)) TO WS-L1
     COMPUTE WS-I = FUNCTION INTEGER(WS-Y)
     MOVE WS-I TO WS-EDIT
     MOVE FUNCTION TRIM(WS-EDIT) TO WS-A2
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-EDIT)) TO WS-L2
     COMPUTE WS-I = FUNCTION INTEGER(WS-Z)
     MOVE WS-I TO WS-EDIT
     MOVE FUNCTION TRIM(WS-EDIT) TO WS-A3
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-EDIT)) TO WS-L3
     MOVE 3 TO WS-N-ARGS
     CALL "BR-RAISE-3" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2 WS-A3 WS-L3 WS-RC
     MOVE 1 TO BR-R-FAILED.

*> The stacks to lay on the slots, in WS-STACKS: the item of with, or the stacks of the source slots of the first source entity.
 GET-SOURCE.
     MOVE 0 TO WS-STACK-COUNT
     IF WS-WITH > 0
         CALL "BX-FIND" USING WS-NAME-ITEM WS-INDEX
         MOVE 1 TO WS-STACK-COUNT
         MOVE BA-IVAL(WS-INDEX) TO WS-ST-ITEM(1)
         MOVE 0 TO WS-ST-VAR(1)
         MOVE 1 TO WS-ST-COUNT(1)
         IF BA-AUX(WS-INDEX) >= 2
             MOVE "cobolcraft.item.components_unsupported" TO WS-KEY
             MOVE 0 TO WS-N-ARGS WS-L1 WS-L2
             MOVE SPACES TO WS-A1 WS-A2
             CALL "BR-RAISE" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2 WS-RC
             MOVE 1 TO BR-R-FAILED
         END-IF
         CALL "BX-FIND" USING WS-NAME-COUNT WS-INDEX
         IF WS-INDEX > 0
             MOVE BA-IVAL(WS-INDEX) TO WS-ST-COUNT(1)
         END-IF
     ELSE
         CALL "BX-FIND" USING WS-NAME-SOURCES WS-INDEX
         IF WS-INDEX > 0
             CALL "BX-RESOLVE" USING WS-INDEX WS-SOURCE-ROWS
         END-IF
         IF WS-INDEX > 0 AND BR-R-FAILED = 0
             CALL "BX-FIND" USING WS-NAME-SOURCE-SLOTS WS-SLOTS-INDEX
             PERFORM READ-SLOTS
             PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-SLOT-COUNT OR BR-R-FAILED = 1
                 CALL "CXB-ITEM-SLOT" USING WS-SOURCE-ROW(1) WS-SLOT(WS-J) WS-AT
                 IF WS-AT = 0
                     MOVE "commands.item.source.no_such_slot" TO WS-KEY
                     PERFORM RAISE-SLOT
                 ELSE
                     ADD 1 TO WS-STACK-COUNT
                     MOVE PL-SLOT-ITEM(WS-SOURCE-ROW(1), WS-AT) TO WS-ST-ITEM(WS-STACK-COUNT)
                     MOVE PL-SLOT-COUNT(WS-SOURCE-ROW(1), WS-AT) TO WS-ST-COUNT(WS-STACK-COUNT)
                     MOVE PL-SLOT-VAR(WS-SOURCE-ROW(1), WS-AT) TO WS-ST-VAR(WS-STACK-COUNT)
                 END-IF
             END-PERFORM
         END-IF
     END-IF.

*> The selected slots of the player WS-ROW set from the stacks; WS-CHANGED counts the slots set.
 SET-ONE.
     MOVE 0 TO WS-CHANGED
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-SLOT-COUNT
         MOVE 0 TO WS-AT
         IF WS-J <= WS-STACK-COUNT
             MOVE WS-J TO WS-AT
         END-IF
         IF WS-FILL > 0
             COMPUTE WS-AT = FUNCTION MOD(WS-J - 1, WS-STACK-COUNT) + 1
         END-IF
         MOVE WS-AT TO WS-SRC-COUNT
         CALL "CXB-ITEM-SLOT" USING WS-ROW WS-SLOT(WS-J) WS-AT
         IF WS-AT > 0 AND WS-SRC-COUNT > 0
             MOVE WS-ST-ITEM(WS-SRC-COUNT) TO PL-SLOT-ITEM(WS-ROW, WS-AT)
             MOVE WS-ST-COUNT(WS-SRC-COUNT) TO PL-SLOT-COUNT(WS-ROW, WS-AT)
             MOVE WS-ST-VAR(WS-SRC-COUNT) TO PL-SLOT-VAR(WS-ROW, WS-AT)
             ADD 1 TO WS-CHANGED
         END-IF
         IF WS-AT > 0 AND WS-SRC-COUNT = 0 AND WS-OVERRIDE > 0
             MOVE 0 TO PL-SLOT-ITEM(WS-ROW, WS-AT) PL-SLOT-COUNT(WS-ROW, WS-AT) PL-SLOT-VAR(WS-ROW, WS-AT)
             ADD 1 TO WS-CHANGED
         END-IF
     END-PERFORM
     IF WS-CHANGED > 0
         CALL "CMD-SEND-INVENTORY" USING WS-ROW
     END-IF.

 MAIN-LINE.
     CALL "BX-FIND" USING WS-NAME-MODIFIER WS-MODIFIER
     CALL "BX-LIT" USING WS-NAME-WITH WS-WITH
     CALL "BX-LIT" USING WS-NAME-FILL WS-FILL
     CALL "BX-LIT" USING WS-NAME-OVERRIDE WS-OVERRIDE
     IF WS-MODIFIER > 0
         MOVE "cobolcraft.item.modifier_unsupported" TO WS-KEY
         MOVE 0 TO WS-N-ARGS WS-L1 WS-L2
         MOVE SPACES TO WS-A1 WS-A2
         CALL "BR-RAISE" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2 WS-RC
         MOVE 1 TO BR-R-FAILED
     END-IF
     IF BR-R-FAILED = 0
         CALL "BX-FIND" USING WS-NAME-SOURCE-POS WS-INDEX
         IF WS-INDEX > 0
             MOVE "commands.item.source.not_a_container" TO WS-KEY
             PERFORM RAISE-BLOCK
         END-IF
     END-IF
     IF BR-R-FAILED = 0
         PERFORM GET-SOURCE
     END-IF
     IF BR-R-FAILED = 0
         CALL "BX-FIND" USING WS-NAME-POS WS-INDEX
         IF WS-INDEX > 0
             MOVE "commands.item.target.not_a_container" TO WS-KEY
             PERFORM RAISE-BLOCK
         END-IF
     END-IF
     IF BR-R-FAILED = 0
         CALL "BX-FIND" USING WS-NAME-TARGETS WS-INDEX
         CALL "BX-RESOLVE" USING WS-INDEX WS-ROWS
     END-IF
     IF BR-R-FAILED = 0
         CALL "BX-FIND" USING WS-NAME-SLOTS WS-SLOTS-INDEX
         PERFORM READ-SLOTS
         MOVE 0 TO WS-TRACKED WS-TOTAL WS-LAST WS-LAST-CHANGED
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BX-COUNT
             MOVE BX-ROW(WS-I) TO WS-ROW
             IF WS-ROW > 0
                 PERFORM SET-ONE
                 IF WS-CHANGED > 0
                     ADD 1 TO WS-TRACKED
                     ADD WS-CHANGED TO WS-TOTAL
                     MOVE WS-ROW TO WS-LAST
                     MOVE WS-CHANGED TO WS-LAST-CHANGED
                 END-IF
             END-IF
         END-PERFORM
         IF WS-TRACKED = 0
             MOVE "commands.item.target.no_such_slot" TO WS-KEY
             PERFORM RAISE-SLOT
         ELSE
             IF WS-TRACKED = 1
                 MOVE "commands.item.entity.replace.success.single" TO WS-KEY
             ELSE
                 MOVE "commands.item.entity.replace.success.multiple" TO WS-KEY
             END-IF
             IF WS-WITH > 0
                 MOVE SPACES TO WS-A1
                 STRING FUNCTION TRIM(WS-KEY) ".known_item" DELIMITED BY SIZE INTO WS-A1
                 MOVE WS-A1 TO WS-KEY
             END-IF
             CALL "BX-KEY" USING PB-TEXT WS-KEY
             IF WS-TRACKED = 1
                 CALL "CMD-TEXT-INT" USING PB-TEXT WS-LAST-CHANGED
                 CALL "CMD-TEXT-ARG" USING PB-TEXT PL-NAME(WS-LAST) PL-NAME-LENGTH(WS-LAST)
             ELSE
                 CALL "CMD-TEXT-INT" USING PB-TEXT WS-TRACKED
             END-IF
             IF WS-WITH > 0
                 MOVE WS-ST-ITEM(1) TO WS-ITEM
                 CALL "CMD-TEXT-ARG" USING PB-TEXT IT-KEY(WS-ITEM + 1) IT-KEY-LENGTH(WS-ITEM + 1)
             END-IF
             CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST
             MOVE WS-TOTAL TO BR-R-RESULT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM CX-ITEM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-ITEM.
*> The forms of item (16 §6.3): replace, fill and override with each holder (entity, block) and source (with, from entity, from block, each with or without its count
*> or modifier), then modify.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 2.
 01 WS-COMMAND             BINARY-LONG VALUE BC-ITEM.
 01 WS-PATH                PIC X(256).
 01 WS-VERBS.
    05 FILLER              PIC X(8) VALUE "replace".
    05 FILLER              PIC X(8) VALUE "fill".
    05 FILLER              PIC X(8) VALUE "override".
 01 WS-VERB-TABLE REDEFINES WS-VERBS.
    05 WS-VERB             PIC X(8) OCCURS 3 TIMES.
 01 WS-HOLDERS.
    05 FILLER              PIC X(48) VALUE "entity <targets:entities> <slots:slots>".
    05 FILLER              PIC X(48) VALUE "block <pos:pos> <slots:slots>".
 01 WS-HOLDER-TABLE REDEFINES WS-HOLDERS.
    05 WS-HOLDER           PIC X(48) OCCURS 2 TIMES.
 01 WS-TAILS.
    05 FILLER              PIC X(96) VALUE "with <item:item>".
    05 FILLER              PIC X(96) VALUE "with <item:item> <count:int:1:99>".
    05 FILLER              PIC X(96) VALUE "from entity <sourceEntities:entities> <sourceSlots:slots>".
    05 FILLER              PIC X(96) VALUE "from entity <sourceEntities:entities> <sourceSlots:slots> <modifier:modifier>".
    05 FILLER              PIC X(96) VALUE "from block <sourcePos:pos> <sourceSlots:slots>".
    05 FILLER              PIC X(96) VALUE "from block <sourcePos:pos> <sourceSlots:slots> <modifier:modifier>".
 01 WS-TAIL-TABLE REDEFINES WS-TAILS.
    05 WS-TAIL             PIC X(96) OCCURS 6 TIMES.
 01 WS-V                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 PROCEDURE DIVISION.
     PERFORM VARYING WS-V FROM 1 BY 1 UNTIL WS-V > 3
         PERFORM VARYING WS-H FROM 1 BY 1 UNTIL WS-H > 2
             PERFORM VARYING WS-T FROM 1 BY 1 UNTIL WS-T > 6
                 MOVE SPACES TO WS-PATH
                 STRING "item " FUNCTION TRIM(WS-VERB(WS-V)) " " FUNCTION TRIM(WS-HOLDER(WS-H)) " " FUNCTION TRIM(WS-TAIL(WS-T))
                     DELIMITED BY SIZE INTO WS-PATH
                 CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE "item modify entity <targets:entities> <slots:slots> <modifier:modifier>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "item modify block <pos:pos> <slots:slots> <modifier:modifier>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     GOBACK.
 END PROGRAM CMDS-REG-ITEM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-LOOT.
*> loot <target> <source> (16 §6.4, level 2). Sources: loot <table>, fish <table> <pos> [<tool> | mainhand | offhand], kill <entity> (the table entities/<path of the type key> in
*> the namespace of the key; a player has none), mine <pos> [<tool> | mainhand | offhand] (the table of the block at the position, BLOCK-DROPS-KEY); the table is rolled with LOOT-ROLL
*> (origin: the position, or the source's; tool for fish and mine; the world seed). Targets: give <players> (INV-ADD, what does not fit is dropped at the player), spawn <pos> (ground items
*> there), replace entity <entities> <slot> [<count>] (the stacks on the player slots from the slot on, at most count of them: CXB-ITEM-SLOT), replace block and insert (no live container
*> block: commands.item.target.not_a_container [x, y, z]). give and spawn tell commands.drop.success.single_with_table [count, item, table] (one stack) or .multiple_with_table
*> [items, table], not broadcast; replace entity tells commands.item.entity.replace.success.single [slots, name] / .multiple [entities], broadcast; a replace that set no slot is
*> commands.drop.no_held_items; no table is commands.drop.no_loot_table.entity / .block [name] (loot and fish: argument.resource_or_id.no_such_element [id, minecraft:loot_table]); the
*> result is the number of items rolled (the slots set for replace). Not done: the component patch of a stack does not reach the inventory (INV-ADD takes none), an inline table, the
*> messages without a table name (every source here has one), the kill and fish context keys other than the origin and this_entity.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 COPY CBLOCKS.
 COPY BRRUN.
 COPY PROTO.
 COPY LOOTCTX.
 01 WS-NAME-ENTITIES       PIC X(32) VALUE "entities".
 01 WS-NAME-SLOT           PIC X(32) VALUE "slot".
 01 WS-NAME-COUNT          PIC X(32) VALUE "count".
 01 WS-NAME-TARGET-POS     PIC X(32) VALUE "targetPos".
 01 WS-NAME-PLAYERS        PIC X(32) VALUE "players".
 01 WS-NAME-TABLE          PIC X(32) VALUE "table".
 01 WS-NAME-POS            PIC X(32) VALUE "pos".
 01 WS-NAME-KILL           PIC X(32) VALUE "target".
 01 WS-NAME-TOOL           PIC X(32) VALUE "tool".
 01 WS-NAME-MAINHAND       PIC X(32) VALUE "mainhand".
 01 WS-NAME-OFFHAND        PIC X(32) VALUE "offhand".
 01 WS-NAME-SPAWN          PIC X(32) VALUE "spawn".
 01 WS-ROWS.
    05 BX-COUNT             BINARY-LONG.
    05 BX-ROW               BINARY-LONG OCCURS 64 TIMES.
 01 WS-KILL-ROWS.
    05 WS-KILL-COUNT        BINARY-LONG.
    05 WS-KILL-ROW          BINARY-LONG OCCURS 64 TIMES.
 01 WS-I-ENTITIES          BINARY-LONG.
 01 WS-I-PLAYERS           BINARY-LONG.
 01 WS-I-TARGET-POS        BINARY-LONG.
 01 WS-I-SPAWN             BINARY-LONG.
 01 WS-I-TABLE             BINARY-LONG.
 01 WS-I-POS               BINARY-LONG.
 01 WS-I-KILL              BINARY-LONG.
 01 WS-I-TOOL              BINARY-LONG.
 01 WS-I-MAINHAND          BINARY-LONG.
 01 WS-I-OFFHAND           BINARY-LONG.
 01 WS-I-SLOT              BINARY-LONG.
 01 WS-I-COUNT             BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-TABLE               PIC X(112).
 01 WS-TABLE-LENGTH        BINARY-LONG.
 01 WS-ID                  PIC X(64).
 01 WS-ID-LENGTH           BINARY-LONG.
 01 WS-NS                  PIC X(48).
 01 WS-PATH                PIC X(64).
 01 WS-ROW                 BINARY-LONG.
 01 WS-ENTITY              BINARY-LONG.
 01 WS-SHOWN               PIC X(48).
 01 WS-SHOWN-LENGTH        BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-HELD                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-AT                  BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-DELAY               BINARY-LONG VALUE 0.
 01 WS-ZERO-V              FLOAT-LONG VALUE 0.
 01 WS-ZERO-Y              FLOAT-LONG VALUE 0.
 01 WS-ZERO-Z              FLOAT-LONG VALUE 0.
 01 WS-PLACED              BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-TRACKED             BINARY-LONG.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-LAST-PLACED         BINARY-LONG.
 01 WS-SLOT-ID             BINARY-LONG.
 01 WS-KEY                 PIC X(72).
 01 WS-BROADCAST           BINARY-LONG VALUE 1.
 01 WS-QUIET               BINARY-LONG VALUE 0.
 01 WS-A1                  PIC X(64).
 01 WS-A2                  PIC X(64).
 01 WS-A3                  PIC X(64).
 01 WS-N-ARGS              BINARY-LONG.
 01 WS-L1                  BINARY-LONG.
 01 WS-L2                  BINARY-LONG.
 01 WS-L3                  BINARY-LONG.
 01 WS-RC                  BINARY-LONG VALUE -1.
 01 WS-EDIT                PIC -(9)9.
 PROCEDURE DIVISION.
     GO TO MAIN-LINE.

*> Raises not_a_container for the position argument WS-INDEX.
 RAISE-BLOCK.
     CALL "BX-POSITION" USING WS-INDEX WS-X WS-Y WS-Z
     MOVE SPACES TO WS-A1 WS-A2 WS-A3
     COMPUTE WS-BX = FUNCTION INTEGER(WS-X)
     MOVE WS-BX TO WS-EDIT
     MOVE FUNCTION TRIM(WS-EDIT) TO WS-A1
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-EDIT)) TO WS-L1
     COMPUTE WS-BX = FUNCTION INTEGER(WS-Y)
     MOVE WS-BX TO WS-EDIT
     MOVE FUNCTION TRIM(WS-EDIT) TO WS-A2
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-EDIT)) TO WS-L2
     COMPUTE WS-BX = FUNCTION INTEGER(WS-Z)
     MOVE WS-BX TO WS-EDIT
     MOVE FUNCTION TRIM(WS-EDIT) TO WS-A3
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-EDIT)) TO WS-L3
     MOVE "commands.item.target.not_a_container" TO WS-KEY
     MOVE 3 TO WS-N-ARGS
     CALL "BR-RAISE-3" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2 WS-A3 WS-L3 WS-RC
     MOVE 1 TO BR-R-FAILED.

*> The tool of fish and mine in the context: an item, the main hand of the source (the held slot; nothing for the console) or the off hand (nothing).
 SET-TOOL.
     IF WS-I-TOOL > 0
         MOVE 1 TO LC-TOOL-SET LC-TOOL-COUNT
         MOVE BA-IVAL(WS-I-TOOL) TO LC-TOOL-ITEM
     END-IF
     IF WS-I-MAINHAND > 0
         MOVE 1 TO LC-TOOL-SET
         IF BS-ROW > 0
             COMPUTE WS-HELD = PL-HELD(BS-ROW) + 1
             MOVE PL-SLOT-ITEM(BS-ROW, WS-HELD) TO LC-TOOL-ITEM
             MOVE PL-SLOT-COUNT(BS-ROW, WS-HELD) TO LC-TOOL-COUNT
             MOVE PL-SLOT-VAR(BS-ROW, WS-HELD) TO LC-TOOL-HANDLE
         END-IF
     END-IF
     IF WS-I-OFFHAND > 0
         MOVE 1 TO LC-TOOL-SET
     END-IF.

*> The table key in WS-TABLE (WS-TABLE-LENGTH) and the context for the source; WS-KIND 1 a named table, 2 kill, 3 mine; WS-TABLE-LENGTH 0 when the source has none.
 ROLL-SOURCE.
     INITIALIZE LOOT-CONTEXT
     MOVE 1 TO LC-ORIGIN-SET
     MOVE BS-X TO LC-X
     MOVE BS-Y TO LC-Y
     MOVE BS-Z TO LC-Z
     MOVE CW-SEED TO LC-WORLD-SEED
     MOVE SPACES TO WS-TABLE
     MOVE 0 TO WS-TABLE-LENGTH
     MOVE 1 TO WS-KIND
     EVALUATE TRUE
         WHEN WS-I-KILL > 0
             MOVE 2 TO WS-KIND
             CALL "BX-RESOLVE" USING WS-I-KILL WS-KILL-ROWS
             MOVE WS-KILL-ROW(1) TO WS-ROW
             CALL "CXB-SHOWN" USING WS-ROW WS-SHOWN WS-SHOWN-LENGTH
             IF WS-ROW < 0 AND BR-R-FAILED = 0
                 MOVE SPACES TO WS-NS WS-PATH
                 UNSTRING WS-SHOWN(1:WS-SHOWN-LENGTH) DELIMITED BY ":" INTO WS-NS WS-PATH
                 STRING FUNCTION TRIM(WS-NS) ":entities/" FUNCTION TRIM(WS-PATH) DELIMITED BY SIZE INTO WS-TABLE
                 MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-TABLE)) TO WS-TABLE-LENGTH
                 MOVE 1 TO LC-THIS-SET
                 MOVE WS-SHOWN TO LC-THIS-TYPE
             END-IF
         WHEN WS-I-POS > 0 AND WS-I-TABLE = 0
             MOVE 3 TO WS-KIND
             PERFORM POSITION-ORIGIN
             PERFORM SET-TOOL
             CALL "WORLD-GET-BLOCK" USING BS-DIM WS-BX WS-BY WS-BZ WS-STATE
             CALL "BLOCK-DROPS-KEY" USING WS-STATE WS-TABLE
             MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-TABLE)) TO WS-TABLE-LENGTH
             MOVE 1 TO LC-STATE-SET
             MOVE WS-STATE TO LC-STATE
         WHEN OTHER
             CALL "BX-NAMESPACED" USING WS-I-TABLE WS-ID WS-ID-LENGTH
             MOVE WS-ID TO WS-TABLE
             MOVE WS-ID-LENGTH TO WS-TABLE-LENGTH
             IF WS-I-POS > 0
                 PERFORM POSITION-ORIGIN
                 PERFORM SET-TOOL
             END-IF
     END-EVALUATE.

*> The position argument WS-I-POS as the origin of the context and as the block WS-BX, WS-BY, WS-BZ.
 POSITION-ORIGIN.
     CALL "BX-POSITION" USING WS-I-POS WS-X WS-Y WS-Z
     MOVE WS-X TO LC-X
     MOVE WS-Y TO LC-Y
     MOVE WS-Z TO LC-Z
     COMPUTE WS-BX = FUNCTION INTEGER(WS-X)
     COMPUTE WS-BY = FUNCTION INTEGER(WS-Y)
     COMPUTE WS-BZ = FUNCTION INTEGER(WS-Z).

*> The failure of a source that has no table.
 NO-TABLE.
     MOVE SPACES TO WS-A1 WS-A2
     EVALUATE WS-KIND
         WHEN 2
             MOVE "commands.drop.no_loot_table.entity" TO WS-KEY
             MOVE WS-SHOWN TO WS-A1
             MOVE WS-SHOWN-LENGTH TO WS-L1
             MOVE 1 TO WS-N-ARGS
         WHEN 3
             MOVE "commands.drop.no_loot_table.block" TO WS-KEY
             COMPUTE WS-BLOCK = CB-S-BLOCK(WS-STATE + 1) + 1
             MOVE CB-KEY(WS-BLOCK) TO WS-A1
             MOVE CB-KEY-LENGTH(WS-BLOCK) TO WS-L1
             MOVE 1 TO WS-N-ARGS
         WHEN OTHER
             MOVE "argument.resource_or_id.no_such_element" TO WS-KEY
             MOVE WS-TABLE TO WS-A1
             MOVE WS-TABLE-LENGTH TO WS-L1
             MOVE "minecraft:loot_table" TO WS-A2
             MOVE 20 TO WS-L2
             MOVE 2 TO WS-N-ARGS
     END-EVALUATE
     CALL "BR-RAISE" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2 WS-RC
     MOVE 1 TO BR-R-FAILED.

*> The stacks to the players WS-ROWS (give): into the inventory, the rest on the ground.
 GIVE-ALL.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BX-COUNT
         MOVE BX-ROW(WS-I) TO WS-ROW
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > LR-COUNT
             CALL "INV-ADD" USING WS-ROW LR-ITEM(WS-K) LR-AMOUNT(WS-K) WS-LEFT
             IF WS-LEFT > 0
                 MOVE PL-Y(WS-ROW) TO WS-Y
                 CALL "GI-SPAWN" USING PL-DIM(WS-ROW) PL-X(WS-ROW) WS-Y PL-Z(WS-ROW) WS-ZERO-V WS-ZERO-Y
                     WS-ZERO-Z LR-ITEM(WS-K) WS-LEFT WS-DELAY WS-NEW
             END-IF
         END-PERFORM
         CALL "CMD-SEND-INVENTORY" USING WS-ROW
     END-PERFORM.

*> The stacks on the ground at the position argument WS-I-TARGET-POS.
 SPAWN-ALL.
     CALL "BX-POSITION" USING WS-I-TARGET-POS WS-X WS-Y WS-Z
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > LR-COUNT
         CALL "GI-SPAWN" USING BS-DIM WS-X WS-Y WS-Z WS-ZERO-V WS-ZERO-Y WS-ZERO-Z LR-ITEM(WS-K) LR-AMOUNT(WS-K)
             WS-DELAY WS-NEW
     END-PERFORM.

*> The stacks on the slots of each player from the slot argument on; WS-TRACKED counts the players that got any, WS-TOTAL the slots set.
 REPLACE-ALL.
     CALL "BX-FIND" USING WS-NAME-SLOT WS-I-SLOT
     MOVE BA-IVAL(WS-I-SLOT) TO WS-SLOT-ID
     MOVE LR-COUNT TO WS-N
     CALL "BX-FIND" USING WS-NAME-COUNT WS-I-COUNT
     IF WS-I-COUNT > 0 AND BA-IVAL(WS-I-COUNT) < WS-N
         MOVE BA-IVAL(WS-I-COUNT) TO WS-N
     END-IF
     MOVE 0 TO WS-TRACKED WS-TOTAL WS-LAST WS-LAST-PLACED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BX-COUNT
         MOVE BX-ROW(WS-I) TO WS-ROW
         MOVE 0 TO WS-PLACED
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-N
             COMPUTE WS-WANT = WS-SLOT-ID + WS-K - 1
             CALL "CXB-ITEM-SLOT" USING WS-ROW WS-WANT WS-AT
             IF WS-AT > 0
                 MOVE LR-ITEM(WS-K) TO PL-SLOT-ITEM(WS-ROW, WS-AT)
                 MOVE LR-AMOUNT(WS-K) TO PL-SLOT-COUNT(WS-ROW, WS-AT)
                 MOVE LR-HANDLE(WS-K) TO PL-SLOT-VAR(WS-ROW, WS-AT)
                 ADD 1 TO WS-PLACED
             END-IF
         END-PERFORM
         IF WS-PLACED > 0
             CALL "CMD-SEND-INVENTORY" USING WS-ROW
             ADD 1 TO WS-TRACKED
             ADD WS-PLACED TO WS-TOTAL
             MOVE WS-ROW TO WS-LAST
             MOVE WS-PLACED TO WS-LAST-PLACED
         END-IF
     END-PERFORM.

*> The drop message of a give or spawn: one stack names its item.
 TELL-DROP.
     MOVE 0 TO WS-TOTAL
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > LR-COUNT
         ADD LR-AMOUNT(WS-K) TO WS-TOTAL
     END-PERFORM
     IF LR-COUNT = 1
         MOVE "commands.drop.success.single_with_table" TO WS-KEY
     ELSE
         MOVE "commands.drop.success.multiple_with_table" TO WS-KEY
     END-IF
     CALL "BX-KEY" USING PB-TEXT WS-KEY
     CALL "CMD-TEXT-INT" USING PB-TEXT WS-TOTAL
     IF LR-COUNT = 1
         CALL "CMD-TEXT-ARG" USING PB-TEXT IT-KEY(LR-ITEM(1) + 1) IT-KEY-LENGTH(LR-ITEM(1) + 1)
     END-IF
     CALL "CMD-TEXT-ARG" USING PB-TEXT WS-TABLE WS-TABLE-LENGTH
     CALL "BR-FEEDBACK" USING PB-TEXT WS-QUIET
     MOVE WS-TOTAL TO BR-R-RESULT.

*> The message of a replace: none set is commands.drop.no_held_items.
 TELL-REPLACE.
     IF WS-TRACKED = 0
         MOVE "commands.drop.no_held_items" TO WS-KEY
         MOVE 0 TO WS-N-ARGS WS-L1 WS-L2
         MOVE SPACES TO WS-A1 WS-A2
         CALL "BR-RAISE" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2 WS-RC
         MOVE 1 TO BR-R-FAILED
     ELSE
         IF WS-TRACKED = 1
             MOVE "commands.item.entity.replace.success.single" TO WS-KEY
         ELSE
             MOVE "commands.item.entity.replace.success.multiple" TO WS-KEY
         END-IF
         CALL "BX-KEY" USING PB-TEXT WS-KEY
         IF WS-TRACKED = 1
             CALL "CMD-TEXT-INT" USING PB-TEXT WS-LAST-PLACED
             CALL "CMD-TEXT-ARG" USING PB-TEXT PL-NAME(WS-LAST) PL-NAME-LENGTH(WS-LAST)
         ELSE
             CALL "CMD-TEXT-INT" USING PB-TEXT WS-TRACKED
         END-IF
         CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST
         MOVE WS-TOTAL TO BR-R-RESULT
     END-IF.

 MAIN-LINE.
     CALL "BX-FIND" USING WS-NAME-ENTITIES WS-I-ENTITIES
     CALL "BX-FIND" USING WS-NAME-PLAYERS WS-I-PLAYERS
     CALL "BX-FIND" USING WS-NAME-TARGET-POS WS-I-TARGET-POS
     CALL "BX-LIT" USING WS-NAME-SPAWN WS-I-SPAWN
     CALL "BX-FIND" USING WS-NAME-TABLE WS-I-TABLE
     CALL "BX-FIND" USING WS-NAME-POS WS-I-POS
     CALL "BX-FIND" USING WS-NAME-KILL WS-I-KILL
     CALL "BX-FIND" USING WS-NAME-TOOL WS-I-TOOL
     CALL "BX-LIT" USING WS-NAME-MAINHAND WS-I-MAINHAND
     CALL "BX-LIT" USING WS-NAME-OFFHAND WS-I-OFFHAND
     IF WS-I-TARGET-POS > 0 AND WS-I-SPAWN = 0
         MOVE WS-I-TARGET-POS TO WS-INDEX
         PERFORM RAISE-BLOCK
     END-IF
     IF BR-R-FAILED = 0
         PERFORM ROLL-SOURCE
     END-IF
     IF BR-R-FAILED = 0 AND WS-TABLE-LENGTH = 0
         PERFORM NO-TABLE
     END-IF
     IF BR-R-FAILED = 0
         CALL "LOOT-ROLL" USING WS-TABLE LOOT-CONTEXT LOOT-RESULT
         IF LR-STATUS = 1
             PERFORM NO-TABLE
         END-IF
     END-IF
     IF BR-R-FAILED = 0
         EVALUATE TRUE
             WHEN WS-I-PLAYERS > 0
                 CALL "BX-RESOLVE" USING WS-I-PLAYERS WS-ROWS
                 IF BR-R-FAILED = 0
                     PERFORM GIVE-ALL
                     PERFORM TELL-DROP
                 END-IF
             WHEN WS-I-TARGET-POS > 0
                 PERFORM SPAWN-ALL
                 PERFORM TELL-DROP
             WHEN OTHER
                 CALL "BX-RESOLVE" USING WS-I-ENTITIES WS-ROWS
                 IF BR-R-FAILED = 0
                     PERFORM REPLACE-ALL
                     PERFORM TELL-REPLACE
                 END-IF
         END-EVALUATE
     END-IF
     .
 END PROGRAM CX-LOOT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-LOOT.
*> The forms of loot (16 §6.4): each target with each source (fish and mine with an item, mainhand, offhand or no tool).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 2.
 01 WS-COMMAND             BINARY-LONG VALUE BC-LOOT.
 01 WS-PATH                PIC X(256).
 01 WS-TARGETS.
    05 FILLER              PIC X(64) VALUE "replace entity <entities:entities> <slot:slot>".
    05 FILLER              PIC X(64) VALUE "replace entity <entities:entities> <slot:slot> <count:int:0>".
    05 FILLER              PIC X(64) VALUE "replace block <targetPos:pos> <slot:slot>".
    05 FILLER              PIC X(64) VALUE "replace block <targetPos:pos> <slot:slot> <count:int:0>".
    05 FILLER              PIC X(64) VALUE "insert <targetPos:pos>".
    05 FILLER              PIC X(64) VALUE "give <players:players>".
    05 FILLER              PIC X(64) VALUE "spawn <targetPos:vec3>".
 01 WS-TARGET-TABLE REDEFINES WS-TARGETS.
    05 WS-TARGET           PIC X(64) OCCURS 7 TIMES.
 01 WS-SOURCES.
    05 FILLER              PIC X(80) VALUE "fish <table:loottable> <pos:pos>".
    05 FILLER              PIC X(80) VALUE "fish <table:loottable> <pos:pos> <tool:item>".
    05 FILLER              PIC X(80) VALUE "fish <table:loottable> <pos:pos> mainhand".
    05 FILLER              PIC X(80) VALUE "fish <table:loottable> <pos:pos> offhand".
    05 FILLER              PIC X(80) VALUE "loot <table:loottable>".
    05 FILLER              PIC X(80) VALUE "kill <target:entity>".
    05 FILLER              PIC X(80) VALUE "mine <pos:pos>".
    05 FILLER              PIC X(80) VALUE "mine <pos:pos> <tool:item>".
    05 FILLER              PIC X(80) VALUE "mine <pos:pos> mainhand".
    05 FILLER              PIC X(80) VALUE "mine <pos:pos> offhand".
 01 WS-SOURCE-TABLE REDEFINES WS-SOURCES.
    05 WS-SOURCE           PIC X(80) OCCURS 10 TIMES.
 01 WS-T                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 PROCEDURE DIVISION.
     PERFORM VARYING WS-T FROM 1 BY 1 UNTIL WS-T > 7
         PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 10
             MOVE SPACES TO WS-PATH
             STRING "loot " FUNCTION TRIM(WS-TARGET(WS-T)) " " FUNCTION TRIM(WS-SOURCE(WS-S)) DELIMITED BY SIZE INTO WS-PATH
             CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM CMDS-REG-LOOT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-ADVANCEMENT.
*> advancement grant|revoke <targets> only <advancement> [<criterion>] | from | until | through <advancement> | everything (16 §6.6, level 2). The advancement
*> engine (the 1866 definitions) is out of scope (BLOCKED), so the set of advancements is empty: an advancement that is named is unknown
*> (advancement.advancementNotFound [id with its namespace], also before any criterion is looked at) and everything affects 0 advancements, which changes
*> nothing and fails with commands.advancement.<grant|revoke>.many.to.<one|many>.failure [0, player name or player count]. Nothing is ever granted or
*> revoked, so no success message, criterion message or commands.advancement.criterionNotFound is reached.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BRRUN.
 01 WS-NAME-TARGETS        PIC X(32) VALUE "targets".
 01 WS-NAME-ADVANCEMENT    PIC X(32) VALUE "advancement".
 01 WS-NAME-GRANT          PIC X(32) VALUE "grant".
 01 WS-ROWS.
    05 BX-COUNT             BINARY-LONG.
    05 BX-ROW               BINARY-LONG OCCURS 64 TIMES.
 01 WS-INDEX               BINARY-LONG.
 01 WS-GRANT               BINARY-LONG.
 01 WS-ID                  PIC X(64).
 01 WS-ID-LENGTH           BINARY-LONG.
 01 WS-COUNT-EDIT          PIC Z(8)9.
 01 WS-KEY                 PIC X(72).
 01 WS-A1                  PIC X(64).
 01 WS-A2                  PIC X(64).
 01 WS-N-ARGS              BINARY-LONG.
 01 WS-L1                  BINARY-LONG.
 01 WS-L2                  BINARY-LONG.
 01 WS-RC                  BINARY-LONG VALUE -1.
 PROCEDURE DIVISION.
     CALL "BX-FIND" USING WS-NAME-TARGETS WS-INDEX
     CALL "BX-RESOLVE" USING WS-INDEX WS-ROWS
     CALL "BX-LIT" USING WS-NAME-GRANT WS-GRANT
     CALL "BX-FIND" USING WS-NAME-ADVANCEMENT WS-INDEX
     IF BR-R-FAILED = 0 AND WS-INDEX > 0
         CALL "BX-NAMESPACED" USING WS-INDEX WS-ID WS-ID-LENGTH
         MOVE "advancement.advancementNotFound" TO WS-KEY
         MOVE 1 TO WS-N-ARGS
         MOVE SPACES TO WS-A1 WS-A2
         MOVE WS-ID(1:WS-ID-LENGTH) TO WS-A1
         MOVE WS-ID-LENGTH TO WS-L1
         MOVE 0 TO WS-L2
         CALL "BR-RAISE" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2 WS-RC
         MOVE 1 TO BR-R-FAILED
     END-IF
     IF BR-R-FAILED = 0
         MOVE SPACES TO WS-A1 WS-A2
         MOVE 2 TO WS-N-ARGS
         MOVE "0" TO WS-A1
         MOVE 1 TO WS-L1
         IF BX-COUNT = 1
             MOVE PL-NAME(BX-ROW(1)) TO WS-A2
             MOVE PL-NAME-LENGTH(BX-ROW(1)) TO WS-L2
             IF WS-GRANT > 0
                 MOVE "commands.advancement.grant.many.to.one.failure" TO WS-KEY
             ELSE
                 MOVE "commands.advancement.revoke.many.to.one.failure" TO WS-KEY
             END-IF
         ELSE
             MOVE BX-COUNT TO WS-COUNT-EDIT
             MOVE FUNCTION TRIM(WS-COUNT-EDIT) TO WS-A2
             MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-COUNT-EDIT)) TO WS-L2
             IF WS-GRANT > 0
                 MOVE "commands.advancement.grant.many.to.many.failure" TO WS-KEY
             ELSE
                 MOVE "commands.advancement.revoke.many.to.many.failure" TO WS-KEY
             END-IF
         END-IF
         CALL "BR-RAISE" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2 WS-RC
         MOVE 1 TO BR-R-FAILED
     END-IF
     GOBACK.
 END PROGRAM CX-ADVANCEMENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-ADVANCEMENT.
*> The forms of advancement (16 §6.6): grant and revoke, each with only (and an optional criterion), from, until, through and everything.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 2.
 01 WS-COMMAND             BINARY-LONG VALUE BC-ADVANCEMENT.
 01 WS-PATH                PIC X(256).
 01 WS-VERBS.
    05 FILLER              PIC X(8) VALUE "grant".
    05 FILLER              PIC X(8) VALUE "revoke".
 01 WS-VERB-TABLE REDEFINES WS-VERBS.
    05 WS-VERB             PIC X(8) OCCURS 2 TIMES.
 01 WS-MODES.
    05 FILLER              PIC X(8) VALUE "from".
    05 FILLER              PIC X(8) VALUE "until".
    05 FILLER              PIC X(8) VALUE "through".
 01 WS-MODE-TABLE REDEFINES WS-MODES.
    05 WS-MODE             PIC X(8) OCCURS 3 TIMES.
 01 WS-V                   BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 PROCEDURE DIVISION.
     PERFORM VARYING WS-V FROM 1 BY 1 UNTIL WS-V > 2
         MOVE SPACES TO WS-PATH
         STRING "advancement " FUNCTION TRIM(WS-VERB(WS-V)) " <targets:players> only <advancement:resloc>" DELIMITED BY SIZE INTO WS-PATH
         CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
         MOVE SPACES TO WS-PATH
         STRING "advancement " FUNCTION TRIM(WS-VERB(WS-V)) " <targets:players> only <advancement:resloc> <criterion:greedy>"
             DELIMITED BY SIZE INTO WS-PATH
         CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
         MOVE SPACES TO WS-PATH
         STRING "advancement " FUNCTION TRIM(WS-VERB(WS-V)) " <targets:players> everything" DELIMITED BY SIZE INTO WS-PATH
         CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
         PERFORM VARYING WS-M FROM 1 BY 1 UNTIL WS-M > 3
             MOVE SPACES TO WS-PATH
             STRING "advancement " FUNCTION TRIM(WS-VERB(WS-V)) " <targets:players> " FUNCTION TRIM(WS-MODE(WS-M))
                 " <advancement:resloc>" DELIMITED BY SIZE INTO WS-PATH
             CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM CMDS-REG-ADVANCEMENT.
