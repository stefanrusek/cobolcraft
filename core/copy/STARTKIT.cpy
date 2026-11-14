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
