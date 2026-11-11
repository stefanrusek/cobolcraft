*> Acceptance test of docs/protocol/43-tint-sources.md section 1 (model in one page): a block has an
*> ordered list of tint sources, an index at or beyond the list gives opaque white, the colour of a
*> quad is multiplied per channel including alpha, a block outside the map has an empty list.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-TINT-43-1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLTINT.
 COPY CLTINTQ.
 COPY TESTLIB.
 01 WS-CASE                PIC X(240).
 01 WS-NAME                PIC X(32).
 01 WS-KIND                BINARY-LONG.
 01 WS-C1                  BINARY-DOUBLE.
 01 WS-C2                  BINARY-DOUBLE.
 01 WS-A                   BINARY-DOUBLE.
 01 WS-B                   BINARY-DOUBLE.
 01 WS-COLOUR              BINARY-DOUBLE.
 01 WS-INDEX               BINARY-LONG.
 01 WS-MODE                BINARY-LONG.
 01 WS-EXPECT              PIC X(8).
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
*>   Item 2: a block that is not in the map has an empty list: every index gives -1 (white).
     MOVE "stone" TO WS-NAME
     MOVE 0 TO WS-INDEX
     MOVE "acceptance US11 43§1 Model in one page: block outside the map has no source" TO WS-CASE
     CALL "TINT-BLOCK-SOURCE" USING WS-NAME WS-INDEX WS-KIND WS-C1 WS-C2
     MOVE "T" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-KIND TO TL-OBSERVED-N
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   V8: a face with tintindex 1 on oak_leaves: no source at index 1, colour -1.
     MOVE "oak_leaves" TO WS-NAME
     MOVE 1 TO WS-INDEX
     MOVE 1 TO WS-MODE
     MOVE WS-NAME TO TQ-NAME
     MOVE WS-INDEX TO TQ-INDEX
     MOVE WS-MODE TO TQ-MODE
     CALL "TINT-BLOCK-COLOR" USING CLIENT-STATE TINT-QUERY
     MOVE TQ-COLOUR TO WS-COLOUR
     MOVE "acceptance US11 43§1 Model in one page: V8 index beyond the list is white" TO WS-CASE
     MOVE "FFFFFFFF" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT WS-COLOUR
*>   A block outside the map and a negative index (tintindex -1) are untinted too.
     MOVE "stone" TO WS-NAME
     MOVE 0 TO WS-INDEX
     MOVE WS-NAME TO TQ-NAME
     MOVE WS-INDEX TO TQ-INDEX
     MOVE WS-MODE TO TQ-MODE
     CALL "TINT-BLOCK-COLOR" USING CLIENT-STATE TINT-QUERY
     MOVE TQ-COLOUR TO WS-COLOUR
     MOVE "acceptance US11 43§1 Model in one page: block outside the map is white" TO WS-CASE
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT WS-COLOUR
     MOVE "spruce_leaves" TO WS-NAME
     MOVE -1 TO WS-INDEX
     MOVE WS-NAME TO TQ-NAME
     MOVE WS-INDEX TO TQ-INDEX
     MOVE WS-MODE TO TQ-MODE
     CALL "TINT-BLOCK-COLOR" USING CLIENT-STATE TINT-QUERY
     MOVE TQ-COLOUR TO WS-COLOUR
     MOVE "acceptance US11 43§1 Model in one page: tintindex -1 means no tint" TO WS-CASE
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT WS-COLOUR
*>   Index i selects element i: spruce leaves element 0 is the constant FF619961.
     MOVE 0 TO WS-INDEX
     MOVE WS-NAME TO TQ-NAME
     MOVE WS-INDEX TO TQ-INDEX
     MOVE WS-MODE TO TQ-MODE
     CALL "TINT-BLOCK-COLOR" USING CLIENT-STATE TINT-QUERY
     MOVE TQ-COLOUR TO WS-COLOUR
     MOVE "acceptance US11 43§1 Model in one page: index selects the element" TO WS-CASE
     MOVE "FF619961" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT WS-COLOUR
*>   V9 first half: pink_petals index 0 is the blank layer (white), index 1 is a source.
     MOVE "pink_petals" TO WS-NAME
     CALL "TINT-BLOCK-SOURCE" USING WS-NAME WS-INDEX WS-KIND WS-C1 WS-C2
     MOVE "acceptance US11 43§1 Model in one page: V9 pink_petals index 0 is constant white"
         TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-KIND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-C1 TO WS-A
     MOVE "acceptance US11 43§1 Model in one page: V9 blank layer colour" TO WS-CASE
     MOVE "FFFFFFFF" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT WS-A
     MOVE 1 TO WS-INDEX
     CALL "TINT-BLOCK-SOURCE" USING WS-NAME WS-INDEX WS-KIND WS-C1 WS-C2
     MOVE "acceptance US11 43§1 Model in one page: V9 pink_petals index 1 is the grass source"
         TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE WS-KIND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Item 4: multiplyColor is a per-channel multiplication including alpha (x * y div 255).
     MOVE 4294967295 TO WS-A
     MOVE 4278190080 TO WS-B
     CALL "TINT-MULTIPLY" USING WS-A WS-B WS-COLOUR
     MOVE "acceptance US11 43§1 Model in one page: white times a colour is the colour" TO WS-CASE
     MOVE "FF000000" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT WS-COLOUR
     MOVE 2566914048 TO WS-A
     MOVE 2147483648 TO WS-B
     CALL "TINT-MULTIPLY" USING WS-A WS-B WS-COLOUR
     MOVE "acceptance US11 43§1 Model in one page: channels multiply with truncation" TO WS-CASE
     MOVE "4C000000" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT WS-COLOUR
     STOP RUN.
 END PROGRAM TEST-TINT-43-1.
 COPY TINTTEST.
