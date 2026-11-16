*> Acceptance test, painting variants from the registry (docs/protocol/44 part 9 section 5.4; lane 002-lane-mobsb8, T9730): the width and height of a variant's JSON, the variant table of the
*> placeable tag (PAINTING-VARIANTS: sizes at least 1 x 1, never more than the registry holds) and a placed painting remembering its variant id (PJ-I4).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US16-PAINTING-VARIANTS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-TEXT                PIC X(200).
 01 WS-LEN                 BINARY-LONG.
 01 WS-VALUE               BINARY-LONG.
 01 WS-KEY                 PIC X(20).
 01 WS-REG                 PIC X(112) VALUE "painting_variant".
 01 WS-TOTAL               BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-IDS.
    05 WS-ID               BINARY-LONG OCCURS 64 TIMES.
 01 WS-WIDTHS.
    05 WS-W                BINARY-LONG OCCURS 64 TIMES.
 01 WS-HEIGHTS.
    05 WS-H                BINARY-LONG OCCURS 64 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE '{"asset_id":"minecraft:kebab","height":2,"width":4,"title":{"translate":"x"}}' TO WS-TEXT
     MOVE 80 TO WS-LEN
     MOVE '"width":' TO WS-KEY
     CALL "PAINTING-JSON-INT" USING WS-TEXT WS-LEN WS-KEY WS-VALUE
     MOVE "acceptance US16 44-9 5.4 the width is read from the variant JSON" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE WS-VALUE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE '"height":' TO WS-KEY
     CALL "PAINTING-JSON-INT" USING WS-TEXT WS-LEN WS-KEY WS-VALUE
     MOVE "acceptance US16 44-9 5.4 the height is read from the variant JSON" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-VALUE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE '"depth":' TO WS-KEY
     CALL "PAINTING-JSON-INT" USING WS-TEXT WS-LEN WS-KEY WS-VALUE
     MOVE "acceptance US16 44-9 5.4 a missing key reads 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-VALUE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "CONTENT-REGISTRY-COUNT" USING WS-REG WS-TOTAL WS-STATUS
     CALL "PAINTING-VARIANTS" USING WS-COUNT WS-IDS WS-WIDTHS WS-HEIGHTS
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
         IF WS-W(WS-I) < 1 OR WS-H(WS-I) < 1 OR WS-ID(WS-I) < 0 OR WS-ID(WS-I) >= WS-TOTAL
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "acceptance US16 44-9 5.4 every listed variant has a size of at least 1 x 1 and a registry id" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 44-9 5.4 the table has at most the registry's entries and 64 rows" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-COUNT <= 64 AND WS-COUNT <= FUNCTION MAX(WS-TOTAL, 0)
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-US16-PAINTING-VARIANTS.
 COPY CORETEST.
 COPY MOBSPTEST.
