*> Implementation test of TINT-MAPS-LOAD (tint-43.cob; 43 section 3.1): the three colormaps are read from
*> textures/colormap/ of the pack stack into TT-MAP-GRASS, -FOLIAGE and -DRY as ARGB (alpha 255), pixel y x 256 + x
*> at index + 1. The fixture pack mini-vanilla has the pixel (x, y, k) with k 1 grass, 2 foliage, 3 dry foliage.
*> With only the built-in pack (no colormaps) the maps stay colour 0. A grass block top at plains (t 0.8, d 0.4)
*> then has the colour of the pixel (51, 173), not black.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-TINT-MAPS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLTINT.
 COPY TESTLIB.
 01 WS-MAP                 BINARY-LONG.
 01 WS-T                   COMP-2.
 01 WS-D                   COMP-2.
 01 WS-COLOUR              BINARY-DOUBLE.
 01 WS-E1                  PIC Z(10)9.
 01 WS-E2                  PIC Z(10)9.
 01 WS-E3                  PIC Z(10)9.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "PACK-STACK-INIT" USING CLIENT-STATE
     CALL "TINT-MAPS-LOAD" USING CLIENT-STATE
     MOVE "tint maps with only the built-in pack (no colormaps) the maps stay colour 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF TT-MAP-GRASS(1) = 0 AND TT-MAP-FOLIAGE(65536) = 0 AND TT-MAP-DRY(300) = 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     ADD 1 TO PK-COUNT
     INITIALIZE PK-PACK(PK-COUNT)
     MOVE 1 TO PK-KIND(PK-COUNT)
     MOVE 3 TO PK-LEVEL(PK-COUNT)
     MOVE "generated/vanilla" TO PK-ID(PK-COUNT)
     MOVE 17 TO PK-ID-LENGTH(PK-COUNT)
     MOVE "client/tests/fixtures/mini-vanilla" TO PK-ROOT(PK-COUNT)
     MOVE 34 TO PK-ROOT-LENGTH(PK-COUNT)
     CALL "PACK-STACK-OPEN" USING CLIENT-STATE
     CALL "PACK-SOURCE-FILES" USING CLIENT-STATE PK-COUNT
     CALL "TINT-MAPS-LOAD" USING CLIENT-STATE

*>   Pixel (x 5, y 7) is index 7 x 256 + 5 + 1; alpha 255, red x, green y, blue k.
     MOVE TT-MAP-GRASS(7 * 256 + 5 + 1) TO WS-E1
     MOVE TT-MAP-FOLIAGE(255 * 256 + 255 + 1) TO WS-E2
     MOVE TT-MAP-DRY(1) TO WS-E3
     MOVE "tint maps the pack's colormaps are loaded as ARGB: grass (5, 7) is FF050701, foliage (255, 255) is "
         & "FFFFFF02, dry foliage (0, 0) is FF000003" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "4278519553 4294967042 4278190083" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3)
         DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Plains (t 0.8, d 0.4): x = trunc(0.2 x 255) = 51, y = trunc((1 - 0.32) x 255) = 173: FF33AD01.
     MOVE 1 TO WS-MAP
     MOVE 0.8 TO WS-T
     MOVE 0.4 TO WS-D
     CALL "TINT-COLORMAP" USING WS-MAP WS-T WS-D WS-COLOUR
     MOVE WS-COLOUR TO WS-E1
     MOVE "tint maps the grass colour of plains is the pixel (51, 173), not black" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "4281576705" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE FUNCTION TRIM(WS-E1) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
