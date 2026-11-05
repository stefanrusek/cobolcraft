*> Item table (standin-content §2; food values §11.5; attack damage §10.4), transcribed.
*> Index by (item id + 1). Tested by core/tests/test_content_tables.cob.
*> IT-PLACES-STATE: the block state a placed item puts, -1 when the item places nothing. Cardstack (6)
*> holds its default state 9 (axis=y, punched=false); on placement the axis follows the clicked face
*> (§1.3: top/bottom y, east/west x, north/south z), punched stays false.
*> IT-MAX-STACK: 0 for cobolcraft:nothing, which never forms a stack (§2 "—").
*> IT-TOOL-CLASS: 0 not a tool, 1 hard-class tool (pry_bar), 2 soft-class tool (trowel); a matching
*> tool divides the block break time by 4 (§2). IT-FOOD: food value, 0 = not food.
*> IT-ATTACK: attack damage when held; 1 also stands for the bare hand (empty slot, §10.4).
 78 ITEM-COUNT                VALUE 18.
 78 ITEM-NOTHING              VALUE 0.
 78 TOOL-BREAK-DIVISOR        VALUE 4.
 01 ITEM-DATA.
    05 FILLER.                                  *> item 0
       10 FILLER PIC X(32) VALUE "cobolcraft:nothing".
       10 FILLER BINARY-LONG VALUE 18.          *> key length
       10 FILLER BINARY-LONG VALUE -1.          *> placed state
       10 FILLER BINARY-LONG VALUE 0.           *> max stack
       10 FILLER BINARY-LONG VALUE 0.           *> tool class
       10 FILLER BINARY-LONG VALUE 0.           *> food value
       10 FILLER BINARY-LONG VALUE 1.           *> attack damage
    05 FILLER.                                  *> item 1
       10 FILLER PIC X(32) VALUE "cobolcraft:baseplate".
       10 FILLER BINARY-LONG VALUE 20.          *> key length
       10 FILLER BINARY-LONG VALUE 1.           *> placed state
       10 FILLER BINARY-LONG VALUE 64.          *> max stack
       10 FILLER BINARY-LONG VALUE 0.           *> tool class
       10 FILLER BINARY-LONG VALUE 0.           *> food value
       10 FILLER BINARY-LONG VALUE 1.           *> attack damage
    05 FILLER.                                  *> item 2
       10 FILLER PIC X(32) VALUE "cobolcraft:greystone".
       10 FILLER BINARY-LONG VALUE 20.          *> key length
       10 FILLER BINARY-LONG VALUE 2.           *> placed state
       10 FILLER BINARY-LONG VALUE 64.          *> max stack
       10 FILLER BINARY-LONG VALUE 0.           *> tool class
       10 FILLER BINARY-LONG VALUE 0.           *> food value
       10 FILLER BINARY-LONG VALUE 1.           *> attack damage
    05 FILLER.                                  *> item 3
       10 FILLER PIC X(32) VALUE "cobolcraft:loam".
       10 FILLER BINARY-LONG VALUE 15.          *> key length
       10 FILLER BINARY-LONG VALUE 3.           *> placed state
       10 FILLER BINARY-LONG VALUE 64.          *> max stack
       10 FILLER BINARY-LONG VALUE 0.           *> tool class
       10 FILLER BINARY-LONG VALUE 0.           *> food value
       10 FILLER BINARY-LONG VALUE 1.           *> attack damage
    05 FILLER.                                  *> item 4
       10 FILLER PIC X(32) VALUE "cobolcraft:turf".
       10 FILLER BINARY-LONG VALUE 15.          *> key length
       10 FILLER BINARY-LONG VALUE 4.           *> placed state
       10 FILLER BINARY-LONG VALUE 64.          *> max stack
       10 FILLER BINARY-LONG VALUE 0.           *> tool class
       10 FILLER BINARY-LONG VALUE 0.           *> food value
       10 FILLER BINARY-LONG VALUE 1.           *> attack damage
    05 FILLER.                                  *> item 5
       10 FILLER PIC X(32) VALUE "cobolcraft:grit".
       10 FILLER BINARY-LONG VALUE 15.          *> key length
       10 FILLER BINARY-LONG VALUE 5.           *> placed state
       10 FILLER BINARY-LONG VALUE 64.          *> max stack
       10 FILLER BINARY-LONG VALUE 0.           *> tool class
       10 FILLER BINARY-LONG VALUE 0.           *> food value
       10 FILLER BINARY-LONG VALUE 1.           *> attack damage
    05 FILLER.                                  *> item 6
       10 FILLER PIC X(32) VALUE "cobolcraft:cardstack".
       10 FILLER BINARY-LONG VALUE 20.          *> key length
       10 FILLER BINARY-LONG VALUE 9.           *> placed state
       10 FILLER BINARY-LONG VALUE 64.          *> max stack
       10 FILLER BINARY-LONG VALUE 0.           *> tool class
       10 FILLER BINARY-LONG VALUE 0.           *> food value
       10 FILLER BINARY-LONG VALUE 1.           *> attack damage
    05 FILLER.                                  *> item 7
       10 FILLER PIC X(32) VALUE "cobolcraft:lucite".
       10 FILLER BINARY-LONG VALUE 17.          *> key length
       10 FILLER BINARY-LONG VALUE 12.          *> placed state
       10 FILLER BINARY-LONG VALUE 64.          *> max stack
       10 FILLER BINARY-LONG VALUE 0.           *> tool class
       10 FILLER BINARY-LONG VALUE 0.           *> food value
       10 FILLER BINARY-LONG VALUE 1.           *> attack damage
    05 FILLER.                                  *> item 8
       10 FILLER PIC X(32) VALUE "cobolcraft:glowtube".
       10 FILLER BINARY-LONG VALUE 19.          *> key length
       10 FILLER BINARY-LONG VALUE 13.          *> placed state
       10 FILLER BINARY-LONG VALUE 64.          *> max stack
       10 FILLER BINARY-LONG VALUE 0.           *> tool class
       10 FILLER BINARY-LONG VALUE 0.           *> food value
       10 FILLER BINARY-LONG VALUE 1.           *> attack damage
    05 FILLER.                                  *> item 9
       10 FILLER PIC X(32) VALUE "cobolcraft:ledger_tile".
       10 FILLER BINARY-LONG VALUE 22.          *> key length
       10 FILLER BINARY-LONG VALUE 15.          *> placed state
       10 FILLER BINARY-LONG VALUE 64.          *> max stack
       10 FILLER BINARY-LONG VALUE 0.           *> tool class
       10 FILLER BINARY-LONG VALUE 0.           *> food value
       10 FILLER BINARY-LONG VALUE 1.           *> attack damage
    05 FILLER.                                  *> item 10
       10 FILLER PIC X(32) VALUE "cobolcraft:pry_bar".
       10 FILLER BINARY-LONG VALUE 18.          *> key length
       10 FILLER BINARY-LONG VALUE -1.          *> placed state
       10 FILLER BINARY-LONG VALUE 1.           *> max stack
       10 FILLER BINARY-LONG VALUE 1.           *> tool class
       10 FILLER BINARY-LONG VALUE 0.           *> food value
       10 FILLER BINARY-LONG VALUE 4.           *> attack damage
    05 FILLER.                                  *> item 11
       10 FILLER PIC X(32) VALUE "cobolcraft:trowel".
       10 FILLER BINARY-LONG VALUE 17.          *> key length
       10 FILLER BINARY-LONG VALUE -1.          *> placed state
       10 FILLER BINARY-LONG VALUE 1.           *> max stack
       10 FILLER BINARY-LONG VALUE 2.           *> tool class
       10 FILLER BINARY-LONG VALUE 0.           *> food value
       10 FILLER BINARY-LONG VALUE 2.           *> attack damage
    05 FILLER.                                  *> item 12
       10 FILLER PIC X(32) VALUE "cobolcraft:grazer_flank".
       10 FILLER BINARY-LONG VALUE 23.          *> key length
       10 FILLER BINARY-LONG VALUE -1.          *> placed state
       10 FILLER BINARY-LONG VALUE 32.          *> max stack
       10 FILLER BINARY-LONG VALUE 0.           *> tool class
       10 FILLER BINARY-LONG VALUE 3.           *> food value
       10 FILLER BINARY-LONG VALUE 1.           *> attack damage
    05 FILLER.                                  *> item 13
       10 FILLER PIC X(32) VALUE "cobolcraft:seared_flank".
       10 FILLER BINARY-LONG VALUE 23.          *> key length
       10 FILLER BINARY-LONG VALUE -1.          *> placed state
       10 FILLER BINARY-LONG VALUE 32.          *> max stack
       10 FILLER BINARY-LONG VALUE 0.           *> tool class
       10 FILLER BINARY-LONG VALUE 8.           *> food value
       10 FILLER BINARY-LONG VALUE 1.           *> attack damage
    05 FILLER.                                  *> item 14
       10 FILLER PIC X(32) VALUE "cobolcraft:sod_cake".
       10 FILLER BINARY-LONG VALUE 19.          *> key length
       10 FILLER BINARY-LONG VALUE -1.          *> placed state
       10 FILLER BINARY-LONG VALUE 16.          *> max stack
       10 FILLER BINARY-LONG VALUE 0.           *> tool class
       10 FILLER BINARY-LONG VALUE 2.           *> food value
       10 FILLER BINARY-LONG VALUE 1.           *> attack damage
    05 FILLER.                                  *> item 15
       10 FILLER PIC X(32) VALUE "cobolcraft:dump_shard".
       10 FILLER BINARY-LONG VALUE 21.          *> key length
       10 FILLER BINARY-LONG VALUE -1.          *> placed state
       10 FILLER BINARY-LONG VALUE 64.          *> max stack
       10 FILLER BINARY-LONG VALUE 0.           *> tool class
       10 FILLER BINARY-LONG VALUE 0.           *> food value
       10 FILLER BINARY-LONG VALUE 1.           *> attack damage
    05 FILLER.                                  *> item 16
       10 FILLER PIC X(32) VALUE "cobolcraft:goto_pad".
       10 FILLER BINARY-LONG VALUE 19.          *> key length
       10 FILLER BINARY-LONG VALUE 16.          *> placed state
       10 FILLER BINARY-LONG VALUE 16.          *> max stack
       10 FILLER BINARY-LONG VALUE 0.           *> tool class
       10 FILLER BINARY-LONG VALUE 0.           *> food value
       10 FILLER BINARY-LONG VALUE 1.           *> attack damage
    05 FILLER.                                  *> item 17
       10 FILLER PIC X(32) VALUE "cobolcraft:slag".
       10 FILLER BINARY-LONG VALUE 15.          *> key length
       10 FILLER BINARY-LONG VALUE 17.          *> placed state
       10 FILLER BINARY-LONG VALUE 64.          *> max stack
       10 FILLER BINARY-LONG VALUE 0.           *> tool class
       10 FILLER BINARY-LONG VALUE 0.           *> food value
       10 FILLER BINARY-LONG VALUE 1.           *> attack damage
 01 ITEM-TABLE REDEFINES ITEM-DATA.
    05 IT-ENTRY OCCURS 18 TIMES.
       10 IT-KEY                PIC X(32).
       10 IT-KEY-LENGTH         BINARY-LONG.
       10 IT-PLACES-STATE       BINARY-LONG.
       10 IT-MAX-STACK          BINARY-LONG.
       10 IT-TOOL-CLASS         BINARY-LONG.
       10 IT-FOOD               BINARY-LONG.
       10 IT-ATTACK             BINARY-LONG.

*> Starting inventory (§2 "Starting inventory", US4-8), given once to a first-time survival player:
*> slot (data-model Inventory numbering, 0 to 8 hotbar), item id, count. Every other slot is empty
*> and the held slot is 0.
 78 START-ITEM-COUNT          VALUE 10.
 01 START-ITEM-DATA.
    05 FILLER.                                  *> slot 0
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 2.
       10 FILLER BINARY-LONG VALUE 64.
    05 FILLER.                                  *> slot 1
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 3.
       10 FILLER BINARY-LONG VALUE 64.
    05 FILLER.                                  *> slot 2
       10 FILLER BINARY-LONG VALUE 2.
       10 FILLER BINARY-LONG VALUE 4.
       10 FILLER BINARY-LONG VALUE 64.
    05 FILLER.                                  *> slot 3
       10 FILLER BINARY-LONG VALUE 3.
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER BINARY-LONG VALUE 64.
    05 FILLER.                                  *> slot 4
       10 FILLER BINARY-LONG VALUE 4.
       10 FILLER BINARY-LONG VALUE 6.
       10 FILLER BINARY-LONG VALUE 64.
    05 FILLER.                                  *> slot 5
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER BINARY-LONG VALUE 7.
       10 FILLER BINARY-LONG VALUE 64.
    05 FILLER.                                  *> slot 6
       10 FILLER BINARY-LONG VALUE 6.
       10 FILLER BINARY-LONG VALUE 8.
       10 FILLER BINARY-LONG VALUE 64.
    05 FILLER.                                  *> slot 7
       10 FILLER BINARY-LONG VALUE 7.
       10 FILLER BINARY-LONG VALUE 9.
       10 FILLER BINARY-LONG VALUE 64.
    05 FILLER.                                  *> slot 8
       10 FILLER BINARY-LONG VALUE 8.
       10 FILLER BINARY-LONG VALUE 10.
       10 FILLER BINARY-LONG VALUE 1.
    05 FILLER.                                  *> slot 9
       10 FILLER BINARY-LONG VALUE 9.
       10 FILLER BINARY-LONG VALUE 11.
       10 FILLER BINARY-LONG VALUE 1.
 01 START-ITEM-TABLE REDEFINES START-ITEM-DATA.
    05 SI-ENTRY OCCURS 10 TIMES.
       10 SI-SLOT               BINARY-LONG.
       10 SI-ITEM               BINARY-LONG.
       10 SI-COUNT              BINARY-LONG.
