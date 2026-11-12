*> Implementation test of GEN-BLOCK-STATE (core/src/gen-job.cob, FD-BLOCK-INDEX): the standard set keeps its block keys without the namespace
*> ("stone"), the generators ask for "minecraft:stone". Before this the lookup found nothing, every generated block was state 0 and a standard
*> world was all air. A key that a row holds with its namespace is still found; an unknown key is state 0.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-GEN-BLOCK-KEYS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CBLOCKS.
 01 WS-KEY                 PIC X(48).
 01 WS-STATE               BINARY-LONG.
 01 WS-E1                  PIC -(5)9.
 01 WS-E2                  PIC -(5)9.
 01 WS-E3                  PIC -(5)9.
 01 WS-N                   BINARY-LONG.
 01 WS-E4                  PIC -(5)9.
 PROCEDURE DIVISION.
     MOVE LOW-VALUES TO CORE-BLOCKS
     MOVE 3 TO CB-BLOCK-COUNT
     MOVE "stone" TO CB-KEY(1)
     MOVE 5 TO CB-KEY-LENGTH(1)
     MOVE 1 TO CB-DEFAULT-STATE(1)
     MOVE "minecraft:dirt" TO CB-KEY(2)
     MOVE 14 TO CB-KEY-LENGTH(2)
     MOVE 10 TO CB-DEFAULT-STATE(2)
     MOVE "stone_bricks" TO CB-KEY(3)
     MOVE 12 TO CB-KEY-LENGTH(3)
     MOVE 77 TO CB-DEFAULT-STATE(3)
     MOVE "minecraft:stone" TO WS-KEY
     CALL "GEN-BLOCK-STATE" USING WS-KEY WS-STATE
     MOVE WS-STATE TO WS-E1
     MOVE "minecraft:dirt" TO WS-KEY
     CALL "GEN-BLOCK-STATE" USING WS-KEY WS-STATE
     MOVE WS-STATE TO WS-E2
     MOVE "minecraft:nothing" TO WS-KEY
     CALL "GEN-BLOCK-STATE" USING WS-KEY WS-STATE
     MOVE WS-STATE TO WS-E3
     MOVE "nothing" TO WS-KEY
     CALL "GEN-BLOCK-STATE" USING WS-KEY WS-STATE
     MOVE WS-STATE TO WS-N
     MOVE WS-N TO WS-E4
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) " " FUNCTION TRIM(WS-E4)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "T" TO TL-MODE
     MOVE "gen block keys minecraft:stone finds the row stone, minecraft:dirt its namespaced row, an unknown key is 0" TO TL-CASE
     MOVE "1 10 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "minecraft:stone_bricks" TO WS-KEY
     CALL "GEN-BLOCK-STATE" USING WS-KEY WS-STATE
     MOVE WS-STATE TO WS-E1
     MOVE SPACES TO TL-OBSERVED
     MOVE FUNCTION TRIM(WS-E1) TO TL-OBSERVED
     MOVE "gen block keys a longer key sharing a prefix (stone_bricks) is not taken for stone" TO TL-CASE
     MOVE "77" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-GEN-BLOCK-KEYS.
