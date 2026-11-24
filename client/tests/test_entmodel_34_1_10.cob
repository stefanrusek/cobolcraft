*> Acceptance test of docs/protocol/34-entity-models-1-shared-model-and-framework.md section 10 (Master index: 161 entity types, renderer, documenting
*> part): the row count, ids 0..160 in order with unique keys, the part counts (13, 16, 18, 14, 16, 10, 32, 42 = V16), spot rows, lookups, and the two
*> types drawn by avatar renderers (159 registered providers + player + mannequin).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTMODEL-34-1-10.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-NAME                PIC X(120).
 01 WS-E                   BINARY-LONG.
 01 WS-O                   BINARY-LONG.
 01 WS-ID3                PIC 999.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-KEY                 PIC X(32).
 01 WS-KEY2                PIC X(32).
 01 WS-RENDERER            PIC X(150).
 01 WS-PART                BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-SUM                 BINARY-LONG.
 01 WS-REG                 BINARY-LONG.
 01 WS-EX                  BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "EM10-COUNT" USING WS-N
     MOVE "161 entity types" TO WS-NAME
     MOVE 161 TO WS-E
     MOVE WS-N TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-BAD WS-SUM WS-REG
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 160
         CALL "EM10-ROW" USING WS-I WS-KEY WS-RENDERER WS-PART
         IF WS-KEY = SPACES OR WS-PART < 2 OR WS-PART > 9
             ADD 1 TO WS-BAD
         END-IF
         CALL "EM10-FIND" USING WS-KEY WS-ID
         IF WS-ID NOT = WS-I
             ADD 1 TO WS-BAD
         END-IF
         CALL "EM6-RENDERER-EXEMPT" USING WS-KEY WS-EX
         IF WS-EX = 0
             ADD 1 TO WS-REG
         END-IF
     END-PERFORM
     MOVE "every id 0..160 has a part 2..9 and finds itself by its unique key" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-BAD TO WS-O
     PERFORM CHECK-NUM
     MOVE "159 registered renderer providers plus player and mannequin" TO WS-NAME
     MOVE 159 TO WS-E
     MOVE WS-REG TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-SUM
     PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > 9
         CALL "EM10-PART-COUNT" USING WS-I WS-N
         ADD WS-N TO WS-SUM
         MOVE SPACES TO WS-NAME
     MOVE WS-I TO WS-ID3
         STRING "part " WS-ID3 " has the count of V16" DELIMITED BY SIZE INTO WS-NAME
         EVALUATE WS-I
             WHEN 2 MOVE 13 TO WS-E
             WHEN 3 MOVE 16 TO WS-E
             WHEN 4 MOVE 18 TO WS-E
             WHEN 5 MOVE 14 TO WS-E
             WHEN 6 MOVE 16 TO WS-E
             WHEN 7 MOVE 10 TO WS-E
             WHEN 8 MOVE 32 TO WS-E
             WHEN OTHER MOVE 42 TO WS-E
         END-EVALUATE
         MOVE WS-N TO WS-O
         PERFORM CHECK-NUM
     END-PERFORM
     MOVE "part counts add up to 161" TO WS-NAME
     MOVE 161 TO WS-E
     MOVE WS-SUM TO WS-O
     PERFORM CHECK-NUM
*>   spot rows
     MOVE 0 TO WS-I
     MOVE "acacia_boat" TO TL-EXPECTED
     PERFORM CHECK-KEY
     MOVE 8 TO WS-E
     PERFORM CHECK-PART
     MOVE "BoatRenderer(ML.ACACIA_BOAT)" TO TL-EXPECTED
     PERFORM CHECK-RENDERER
     MOVE 2 TO WS-I
     MOVE "allay" TO TL-EXPECTED
     PERFORM CHECK-KEY
     MOVE 3 TO WS-E
     PERFORM CHECK-PART
     MOVE "AllayRenderer" TO TL-EXPECTED
     PERFORM CHECK-RENDERER
     MOVE 37 TO WS-I
     MOVE "donkey" TO TL-EXPECTED
     PERFORM CHECK-KEY
     MOVE "DonkeyRenderer(LT.DONKEY_SADDLE, ML.DONKEY_SADDLE, DonkeyRenderer.Type.DONKEY, DonkeyRenderer.Type.DONKEY_BABY)" TO TL-EXPECTED
     PERFORM CHECK-RENDERER
     MOVE 4 TO WS-E
     PERFORM CHECK-PART
     MOVE 84 TO WS-I
     MOVE "mannequin" TO TL-EXPECTED
     PERFORM CHECK-KEY
     MOVE "AvatarRenderer (WIDE / SLIM; mannequin map; 12 §7)" TO TL-EXPECTED
     PERFORM CHECK-RENDERER
     MOVE 159 TO WS-I
     MOVE "player" TO TL-EXPECTED
     PERFORM CHECK-KEY
     MOVE 160 TO WS-I
     MOVE "fishing_bobber" TO TL-EXPECTED
     PERFORM CHECK-KEY
     MOVE "FishingHookRenderer" TO TL-EXPECTED
     PERFORM CHECK-RENDERER
     MOVE 9 TO WS-E
     PERFORM CHECK-PART
     MOVE 161 TO WS-I
     CALL "EM10-ROW" USING WS-I WS-KEY WS-RENDERER WS-PART
     MOVE "an id past the end has no row" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-PART TO WS-O
     PERFORM CHECK-NUM
     MOVE "nothing_here" TO WS-KEY
     CALL "EM10-FIND" USING WS-KEY WS-ID
     MOVE "an unknown key is -1" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-ID TO WS-O
     PERFORM CHECK-NUM
     MOVE "cow" TO WS-KEY
     CALL "EM10-FIND" USING WS-KEY WS-ID
     MOVE "cow is id 30" TO WS-NAME
     MOVE 30 TO WS-E
     MOVE WS-ID TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-I
     CALL "EM10-PART-COUNT" USING WS-I WS-N
     MOVE "part 1 documents no entity" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-N TO WS-O
     PERFORM CHECK-NUM
     STOP RUN.

 CHECK-KEY.
     CALL "EM10-ROW" USING WS-I WS-KEY2 WS-RENDERER WS-PART
     MOVE SPACES TO TL-CASE
     MOVE WS-I TO WS-ID3
     STRING "acceptance US15 34-1§10 Master index: 161 entity types, renderer, documenting part: key of id " WS-ID3 DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE WS-KEY2 TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-RENDERER.
     CALL "EM10-ROW" USING WS-I WS-KEY2 WS-RENDERER WS-PART
     MOVE SPACES TO TL-CASE
     MOVE WS-I TO WS-ID3
     STRING "acceptance US15 34-1§10 Master index: 161 entity types, renderer, documenting part: renderer of id " WS-ID3 DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE WS-RENDERER TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-PART.
     CALL "EM10-ROW" USING WS-I WS-KEY2 WS-RENDERER WS-PART
     MOVE SPACES TO WS-NAME
     MOVE WS-I TO WS-ID3
     STRING "part of id " WS-ID3 DELIMITED BY SIZE INTO WS-NAME
     MOVE WS-PART TO WS-O
     PERFORM CHECK-NUM.

 CHECK-NUM.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-1§10 Master index: 161 entity types, renderer, documenting part: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ENTMODEL-34-1-10.
