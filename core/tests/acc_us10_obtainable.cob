*> Acceptance test, SC-008 (spec US10; tasks T549; standin-content §13 "How each ingredient is
*> obtained", §2, §5.2, §11.5, §12, §15.2): every recipe result and every food item is obtainable
*> in survival. The obtainable set is a closure over the content tables: the §2 starting inventory
*> (ITEMS.cpy), the yields of the blocks the generators place and a survival player can break (the
*> item that places the block, §1.3), the mob yields (MOBS.cpy), then every recipe (RECIPES.cpy)
*> whose ingredients are all obtainable adds its result, until nothing changes. The claim holds for
*> every FR-009 setting, so it is checked twice: with hostile mobs on, and with them off (no
*> hostile mob's yield).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US10-OBTAINABLE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CBLOCKS.
 COPY CITEMS.
 COPY STARTKIT.
 COPY MOBS.
 *> Blocks the generators place that survival breaking yields (baseplate refuses, §1.3): §5.2
*> greystone, loam, turf, grit, the marker pillars' cardstack, lucite and glowtube; §15.2
*> greystone, slag and glowtube.
 01 WS-GENERATED-DATA.
    05 FILLER BINARY-LONG VALUE 2.              *> greystone
    05 FILLER BINARY-LONG VALUE 3.              *> loam
    05 FILLER BINARY-LONG VALUE 4.              *> turf
    05 FILLER BINARY-LONG VALUE 5.              *> grit
    05 FILLER BINARY-LONG VALUE 6.              *> cardstack
    05 FILLER BINARY-LONG VALUE 7.              *> lucite
    05 FILLER BINARY-LONG VALUE 8.              *> glowtube
    05 FILLER BINARY-LONG VALUE 11.             *> slag
 01 WS-GENERATED-TABLE REDEFINES WS-GENERATED-DATA.
    05 WS-GENERATED        BINARY-LONG OCCURS 8 TIMES.
 01 WS-HAVE-TABLE.
    05 WS-HAVE             PIC 9 OCCURS 18 TIMES.
 01 WS-HOSTILE-ON          PIC 9.
 01 WS-CHANGED             PIC 9.
 01 WS-ALL                 PIC 9.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-EDIT                PIC Z9.
 01 WS-SETTING             PIC X(16).
 PROCEDURE DIVISION.
     MOVE 1 TO WS-HOSTILE-ON
     MOVE "hostile mobs on" TO WS-SETTING
     PERFORM COMPUTE-CLOSURE
     PERFORM CHECK-ALL
     MOVE 0 TO WS-HOSTILE-ON
     MOVE "hostile mobs off" TO WS-SETTING
     PERFORM COMPUTE-CLOSURE
     PERFORM CHECK-ALL
     STOP RUN.

*> The obtainable items (WS-HAVE(item + 1) = 1) for the current setting.
 COMPUTE-CLOSURE.
     INITIALIZE WS-HAVE-TABLE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > START-ITEM-COUNT
         MOVE 1 TO WS-HAVE(SI-ITEM(WS-I) + 1)
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > IT-COUNT
             MOVE IT-PLACES-STATE(WS-J) TO WS-STATE
             IF WS-STATE >= 0
                 IF CB-S-BLOCK(WS-STATE + 1) = WS-GENERATED(WS-I)
                     MOVE 1 TO WS-HAVE(WS-J)
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > MOB-TYPE-COUNT
         IF MB-KIND(WS-I) = MOB-PASSIVE OR WS-HOSTILE-ON = 1
             MOVE 1 TO WS-HAVE(MB-YIELD-ITEM(WS-I) + 1)
         END-IF
     END-PERFORM
     MOVE 1 TO WS-CHANGED
     PERFORM UNTIL WS-CHANGED = 0
         MOVE 0 TO WS-CHANGED
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RP-COUNT
             MOVE 1 TO WS-ALL
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > RP-LINE-COUNT(WS-I)
                 IF WS-HAVE(RP-IN-ITEM(WS-I, WS-K) + 1) = 0
                     MOVE 0 TO WS-ALL
                 END-IF
             END-PERFORM
             IF WS-ALL = 1 AND WS-HAVE(RP-RESULT-ITEM(WS-I) + 1) = 0
                 MOVE 1 TO WS-HAVE(RP-RESULT-ITEM(WS-I) + 1)
                 MOVE 1 TO WS-CHANGED
             END-IF
         END-PERFORM
     END-PERFORM.

*> One case per recipe (its ingredients and result obtainable) and per food item.
 CHECK-ALL.
     MOVE "T" TO TL-MODE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RP-COUNT
         MOVE SPACES TO TL-CASE
         COMPUTE WS-EDIT = WS-I - 1
         MOVE RP-RESULT-ITEM(WS-I) TO WS-ITEM
         STRING "acceptance SC-008 given " FUNCTION TRIM(WS-SETTING) " when the content tables "
             "are closed over then recipe " FUNCTION TRIM(WS-EDIT) " can be crafted and its "
             "result " IT-KEY(WS-ITEM + 1)(1:IT-KEY-LENGTH(WS-ITEM + 1)) " is obtainable"
             DELIMITED BY SIZE INTO TL-CASE
         MOVE "obtainable" TO TL-EXPECTED
         MOVE "obtainable" TO TL-OBSERVED
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > RP-LINE-COUNT(WS-I)
             MOVE RP-IN-ITEM(WS-I, WS-K) TO WS-ITEM
             IF WS-HAVE(WS-ITEM + 1) = 0
                 MOVE SPACES TO TL-OBSERVED
                 STRING "missing ingredient " IT-KEY(WS-ITEM + 1)(1:IT-KEY-LENGTH(WS-ITEM + 1))
                     DELIMITED BY SIZE INTO TL-OBSERVED
             END-IF
         END-PERFORM
         IF WS-HAVE(RP-RESULT-ITEM(WS-I) + 1) = 0
             MOVE "result not obtainable" TO TL-OBSERVED
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > IT-COUNT
         IF IT-FOOD(WS-J) > 0
             MOVE SPACES TO TL-CASE
             STRING "acceptance SC-008 given " FUNCTION TRIM(WS-SETTING) " when the content "
                 "tables are closed over then the food item "
                 IT-KEY(WS-J)(1:IT-KEY-LENGTH(WS-J)) " is obtainable"
                 DELIMITED BY SIZE INTO TL-CASE
             MOVE "obtainable" TO TL-EXPECTED
             MOVE "not obtainable" TO TL-OBSERVED
             IF WS-HAVE(WS-J) = 1
                 MOVE "obtainable" TO TL-OBSERVED
             END-IF
             CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         END-IF
     END-PERFORM.
 END PROGRAM ACC-US10-OBTAINABLE.
