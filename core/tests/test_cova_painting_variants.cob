*> Implementation test (coverage lane A; docs/protocol/44 part 9 section 5.4; core/src/decor-44d.cob): the painting variants of a registry that holds five entries of which four are in
*> the placeable tag and one of those has no height: the three usable ones are listed with their sizes (the fixture core/tests/fixtures/painting-registry).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVA-PAINTING-VARIANTS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 01 WS-CASE                PIC X(240).
 01 WS-E                   BINARY-DOUBLE.
 01 WS-O                   BINARY-DOUBLE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-REG-DIR             PIC X(1100) VALUE "core/tests/fixtures/painting-registry".
 01 WS-STATUS              BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-IDS.
    05 WS-ID               BINARY-LONG OCCURS 64 TIMES.
 01 WS-WIDTHS.
    05 WS-W                BINARY-LONG OCCURS 64 TIMES.
 01 WS-HEIGHTS.
    05 WS-H                BINARY-LONG OCCURS 64 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-AREA                BINARY-LONG.
 01 WS-SIZES               BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     CALL "REGISTRY-LOAD-ALL" USING WS-REG-DIR WS-STATUS
     MOVE "test cova painting variants the registry fixture loads" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-STATUS TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
     CALL "TAGS-LOAD-ALL" USING WS-REG-DIR WS-STATUS
     MOVE "test cova painting variants the tag fixture loads" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-STATUS TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
     CALL "PAINTING-VARIANTS" USING WS-COUNT WS-IDS WS-WIDTHS WS-HEIGHTS
     MOVE "test cova painting variants three placeable variants with a size are listed" TO WS-CASE
     MOVE 3 TO WS-E
     MOVE WS-COUNT TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
     MOVE 0 TO WS-AREA
     MOVE 0 TO WS-SIZES
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
         COMPUTE WS-AREA = WS-AREA + WS-W(WS-I) * WS-H(WS-I)
         COMPUTE WS-SIZES = WS-SIZES + WS-W(WS-I) * 10 + WS-H(WS-I)
     END-PERFORM
     MOVE "test cova painting variants their sizes are 1 x 1, 1 x 2 and 2 x 2 (area 7)" TO WS-CASE
     MOVE 7 TO WS-E
     MOVE WS-AREA TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
     MOVE "test cova painting variants the width and height are read from each entry (sum of w x 10 + h)" TO WS-CASE
     MOVE 11 TO WS-E
     ADD 12 TO WS-E
     ADD 22 TO WS-E
     MOVE WS-SIZES TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
     STOP RUN.
 END PROGRAM TEST-COVA-PAINTING-VARIANTS.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY COVATEST.
