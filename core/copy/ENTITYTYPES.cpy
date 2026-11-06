*> Entity type table (standin-content §3, sizes repeated in §12.1), transcribed.
*> Index by (entity type id + 1). Tested by core/tests/test_content_tables.cob.
*> Width, height and eye height are integer THOUSANDTHS of a block (0.7 -> 700). The collision box is
*> centred on the position horizontally and runs from the position's y upward (§3).
 78 ET-OPERATOR               VALUE 0.
 78 ET-LOOSE-ITEM             VALUE 1.
 78 ET-SODGRAZER              VALUE 2.
 78 ET-ABEND                  VALUE 3.
 78 ENTITY-TYPE-COUNT         VALUE 4.
 01 ENTITY-TYPE-DATA.
    05 FILLER.                                  *> entity type 0
       10 FILLER PIC X(32) VALUE "cobolcraft:operator".
       10 FILLER BINARY-LONG VALUE 19.          *> key length
       10 FILLER BINARY-LONG VALUE 700.         *> width/1000
       10 FILLER BINARY-LONG VALUE 1750.        *> height/1000
       10 FILLER BINARY-LONG VALUE 1600.        *> eye height/1000
    05 FILLER.                                  *> entity type 1
       10 FILLER PIC X(32) VALUE "cobolcraft:loose_item".
       10 FILLER BINARY-LONG VALUE 21.          *> key length
       10 FILLER BINARY-LONG VALUE 300.         *> width/1000
       10 FILLER BINARY-LONG VALUE 300.         *> height/1000
       10 FILLER BINARY-LONG VALUE 150.         *> eye height/1000
    05 FILLER.                                  *> entity type 2
       10 FILLER PIC X(32) VALUE "cobolcraft:sodgrazer".
       10 FILLER BINARY-LONG VALUE 20.          *> key length
       10 FILLER BINARY-LONG VALUE 900.         *> width/1000
       10 FILLER BINARY-LONG VALUE 900.         *> height/1000
       10 FILLER BINARY-LONG VALUE 700.         *> eye height/1000
    05 FILLER.                                  *> entity type 3
       10 FILLER PIC X(32) VALUE "cobolcraft:abend".
       10 FILLER BINARY-LONG VALUE 16.          *> key length
       10 FILLER BINARY-LONG VALUE 750.         *> width/1000
       10 FILLER BINARY-LONG VALUE 750.         *> height/1000
       10 FILLER BINARY-LONG VALUE 500.         *> eye height/1000
 01 ENTITY-TYPE-TABLE REDEFINES ENTITY-TYPE-DATA.
    05 ET-ENTRY OCCURS 4 TIMES.
       10 ET-KEY                PIC X(32).
       10 ET-KEY-LENGTH         BINARY-LONG.
       10 ET-WIDTH-MILLI        BINARY-LONG.
       10 ET-HEIGHT-MILLI       BINARY-LONG.
       10 ET-EYE-MILLI          BINARY-LONG.
