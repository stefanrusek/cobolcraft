*> Implementation test of the core's item, entity-type and recipe tables (T0327; CITEMS.cpy, content-tables.cob):
*> CORE-TABLES-OPEN builds them from the content set. Expected rows are those of docs/design/standin-content.md
*> section 2 (items), section 3 and the built-in layer's sizes (0.6 x 1.8, 0.25 x 0.25, 0.9 x 0.9, 0.75 x 0.75) and
*> section 13 (the nine shapeless recipes in display order, ingredient lines in order of first use; the
*> crafting bench's shaped recipe is not held). The roles resolve by key.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CORE-TABLES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONTENT.
 COPY CBLOCKS.
 COPY CITEMS.
 01 WS-DIR                 PIC X(1100).
 01 WS-TYPE                BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-L                   BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-E4                  PIC -(9)9.
 01 WS-E5                  PIC -(9)9.
 01 WS-E6                  PIC -(9)9.
 01 WS-ITEM-ROWS.
    05 FILLER PIC X(60) VALUE "cobolcraft:nothing -1 0 0 0 1".
    05 FILLER PIC X(60) VALUE "cobolcraft:baseplate 1 64 0 0 1".
    05 FILLER PIC X(60) VALUE "cobolcraft:greystone 2 64 0 0 1".
    05 FILLER PIC X(60) VALUE "cobolcraft:loam 3 64 0 0 1".
    05 FILLER PIC X(60) VALUE "cobolcraft:turf 4 64 0 0 1".
    05 FILLER PIC X(60) VALUE "cobolcraft:grit 5 64 0 0 1".
    05 FILLER PIC X(60) VALUE "cobolcraft:cardstack 9 64 0 0 1".
    05 FILLER PIC X(60) VALUE "cobolcraft:lucite 12 64 0 0 1".
    05 FILLER PIC X(60) VALUE "cobolcraft:glowtube 13 64 0 0 1".
    05 FILLER PIC X(60) VALUE "cobolcraft:ledger_tile 15 64 0 0 1".
    05 FILLER PIC X(60) VALUE "cobolcraft:pry_bar -1 1 1 0 4".
    05 FILLER PIC X(60) VALUE "cobolcraft:trowel -1 1 2 0 2".
    05 FILLER PIC X(60) VALUE "cobolcraft:grazer_flank -1 32 0 3 1".
    05 FILLER PIC X(60) VALUE "cobolcraft:seared_flank -1 32 0 8 1".
    05 FILLER PIC X(60) VALUE "cobolcraft:sod_cake -1 16 0 2 1".
    05 FILLER PIC X(60) VALUE "cobolcraft:dump_shard -1 64 0 0 1".
    05 FILLER PIC X(60) VALUE "cobolcraft:goto_pad 16 16 0 0 1".
    05 FILLER PIC X(60) VALUE "cobolcraft:slag 17 64 0 0 1".
    05 FILLER PIC X(60) VALUE "cobolcraft:crafting_bench 18 64 0 0 1".
 01 WS-ITEM-TABLE REDEFINES WS-ITEM-ROWS.
    05 WS-ITEM-ROW         PIC X(60) OCCURS 19 TIMES.
 01 WS-ENTITY-ROWS.
    05 FILLER PIC X(60) VALUE "cobolcraft:operator 600 1800".
    05 FILLER PIC X(60) VALUE "cobolcraft:loose_item 250 250".
    05 FILLER PIC X(60) VALUE "cobolcraft:sodgrazer 900 900".
    05 FILLER PIC X(60) VALUE "cobolcraft:abend 750 750".
 01 WS-ENTITY-TABLE REDEFINES WS-ENTITY-ROWS.
    05 WS-ENTITY-ROW       PIC X(60) OCCURS 4 TIMES.
 01 WS-RECIPE-ROWS.
    05 FILLER PIC X(60) VALUE "1 2x4 > 9x2".
    05 FILLER PIC X(60) VALUE "1 5x4 > 7x2".
    05 FILLER PIC X(60) VALUE "2 2x3 6x1 > 10x1".
    05 FILLER PIC X(60) VALUE "2 2x2 6x1 > 11x1".
    05 FILLER PIC X(60) VALUE "2 7x1 15x1 > 8x2".
    05 FILLER PIC X(60) VALUE "2 4x4 3x1 > 14x1".
    05 FILLER PIC X(60) VALUE "2 12x2 8x1 > 13x2".
    05 FILLER PIC X(60) VALUE "3 9x4 15x2 8x1 > 16x1".
    05 FILLER PIC X(60) VALUE "2 6x2 7x2 > 15x1".
 01 WS-RECIPE-TABLE REDEFINES WS-RECIPE-ROWS.
    05 WS-RECIPE-ROW       PIC X(60) OCCURS 9 TIMES.
 PROCEDURE DIVISION.
     MOVE SPACES TO WS-DIR
     MOVE CT-TYPE-COBOLCRAFT TO WS-TYPE
     CALL "CONTENT-OPEN" USING WS-TYPE WS-DIR WS-STATUS
     CALL "BLOCKS-OPEN"
     CALL "CORE-TABLES-OPEN"
     MOVE "N" TO TL-MODE
     MOVE "test core tables 19 items, 4 entity types, 9 recipes" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 19 * 10000 + 4 * 100 + 9
     COMPUTE TL-OBSERVED-N = IT-COUNT * 10000 + ET-COUNT * 100 + RP-COUNT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 19
         MOVE IT-KEY-LENGTH(WS-I) TO WS-LEN
         MOVE IT-PLACES-STATE(WS-I) TO WS-E1
         MOVE IT-MAX-STACK(WS-I) TO WS-E2
         MOVE IT-TOOL-CLASS(WS-I) TO WS-E3
         MOVE IT-FOOD(WS-I) TO WS-E4
         MOVE IT-ATTACK(WS-I) TO WS-E5
         MOVE SPACES TO TL-OBSERVED TL-CASE
         STRING IT-KEY(WS-I)(1:WS-LEN) " " FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " "
             FUNCTION TRIM(WS-E3) " " FUNCTION TRIM(WS-E4) " " FUNCTION TRIM(WS-E5)
             DELIMITED BY SIZE INTO TL-OBSERVED
         MOVE WS-ITEM-ROW(WS-I) TO TL-EXPECTED
         MOVE WS-I TO WS-E6
         STRING "test core tables item row " FUNCTION TRIM(WS-E6) DELIMITED BY SIZE INTO TL-CASE
         MOVE "T" TO TL-MODE
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM

     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         MOVE ET-KEY-LENGTH(WS-I) TO WS-LEN
         MOVE ET-WIDTH-MILLI(WS-I) TO WS-E1
         MOVE ET-HEIGHT-MILLI(WS-I) TO WS-E2
         MOVE SPACES TO TL-OBSERVED TL-CASE
         STRING ET-KEY(WS-I)(1:WS-LEN) " " FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2)
             DELIMITED BY SIZE INTO TL-OBSERVED
         MOVE WS-ENTITY-ROW(WS-I) TO TL-EXPECTED
         MOVE WS-I TO WS-E6
         STRING "test core tables entity type row " FUNCTION TRIM(WS-E6) DELIMITED BY SIZE INTO TL-CASE
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM

     MOVE "test core tables entity roles operator, loose item, sodgrazer, abend" TO TL-CASE
     MOVE CR-OPERATOR TO WS-E1
     MOVE CR-LOOSE-ITEM TO WS-E2
     MOVE CR-SODGRAZER TO WS-E3
     MOVE CR-ABEND TO WS-E4
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) " " FUNCTION TRIM(WS-E4)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "0 1 2 3" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 9
         MOVE RP-LINE-COUNT(WS-I) TO WS-E1
         MOVE SPACES TO TL-OBSERVED TL-CASE
         STRING FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED
         PERFORM VARYING WS-L FROM 1 BY 1 UNTIL WS-L > RP-LINE-COUNT(WS-I)
             MOVE RP-IN-ITEM(WS-I, WS-L) TO WS-E2
             MOVE RP-IN-COUNT(WS-I, WS-L) TO WS-E3
             STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-E2) "x" FUNCTION TRIM(WS-E3)
                 DELIMITED BY SIZE INTO TL-OBSERVED
         END-PERFORM
         MOVE RP-RESULT-ITEM(WS-I) TO WS-E4
         MOVE RP-RESULT-COUNT(WS-I) TO WS-E5
         STRING FUNCTION TRIM(TL-OBSERVED) " > " FUNCTION TRIM(WS-E4) "x" FUNCTION TRIM(WS-E5)
             DELIMITED BY SIZE INTO TL-OBSERVED
         MOVE WS-RECIPE-ROW(WS-I) TO TL-EXPECTED
         MOVE WS-I TO WS-E6
         STRING "test core tables recipe " FUNCTION TRIM(WS-E6) DELIMITED BY SIZE INTO TL-CASE
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     STOP RUN.
 END PROGRAM TEST-CORE-TABLES.
