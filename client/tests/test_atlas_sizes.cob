*> Implementation test of client/src/atlas.cob for packs of any sprite size and count (US3; FR-010): a pack with
*> 300 sprites of 16 pixels and 6 of 32 pixels (fixture "many") gives more than 128 sprites, each with the size of
*> its own image (not a constant), no sprite overlapping another, every pixel kept, and an atlas that stays
*> within the 16384 pixel texture limit.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ATLAS-SIZES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/client-test-atlas-sizes".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 29.
 01 WS-NAMES               PIC X(256) VALUE "many".
 01 WS-IDS                 PIC X(256) VALUE "file/many".
 01 WS-NAME                PIC X(80).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-SPRITE              BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-PIXEL               PIC X(32).
 01 WS-E1                  PIC 9(5).
 01 WS-E2                  PIC 9(3).
 01 WS-E3                  PIC 9(3).
 01 WS-E4                  PIC 9(5).
 PROCEDURE DIVISION.
     CALL "TEST-PACK-START" USING CLIENT-STATE WS-DIR WS-DIR-LENGTH WS-NAMES
     CALL "TEST-PACK-ENABLE" USING CLIENT-STATE WS-IDS
     MOVE "many:block/b299" TO WS-NAME
     MOVE 15 TO WS-NAME-LENGTH
     CALL "ATLAS-FIND" USING CLIENT-STATE WS-NAME WS-NAME-LENGTH WS-SPRITE
     MOVE "atlas a pack with 306 sprites gives the last small sprite (b299) a place, with its own size"
         TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     MOVE AT-SW(WS-SPRITE) TO WS-E2
     MOVE AT-SH(WS-SPRITE) TO WS-E3
     STRING FUNCTION CHAR(49 + FUNCTION MIN(WS-SPRITE, 1)) " " WS-E2 "x" WS-E3 DELIMITED BY SIZE
         INTO TL-OBSERVED
     MOVE "1 016x016" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "many:block/big5" TO WS-NAME
     MOVE 15 TO WS-NAME-LENGTH
     CALL "ATLAS-FIND" USING CLIENT-STATE WS-NAME WS-NAME-LENGTH WS-SPRITE
     MOVE "atlas a 32 pixel image keeps its size (the sprite size comes from the pack, not a constant)"
         TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE AT-SW(WS-SPRITE) TO WS-E2
     MOVE AT-SH(WS-SPRITE) TO WS-E3
     STRING WS-E2 "x" WS-E3 DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "032x032" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-PIXEL" USING CLIENT-STATE WS-NAME WS-NAME-LENGTH WS-PIXEL
     MOVE "atlas the 32 pixel sprite's pixels are the pack's (9,9,105)" TO TL-CASE
     MOVE "9,9,105,255" TO TL-EXPECTED
     MOVE WS-PIXEL TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   No two sprites overlap, and all of them lie inside the atlas.
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > AT-SPRITE-COUNT
         IF AT-X(WS-S) + AT-SW(WS-S) > AT-W OR AT-Y(WS-S) + AT-SH(WS-S) > AT-H
             ADD 1 TO WS-BAD
         END-IF
         PERFORM VARYING WS-T FROM 1 BY 1 UNTIL WS-T >= WS-S
             IF AT-X(WS-S) < AT-X(WS-T) + AT-SW(WS-T) AND AT-X(WS-T) < AT-X(WS-S) + AT-SW(WS-S)
                     AND AT-Y(WS-S) < AT-Y(WS-T) + AT-SH(WS-T)
                     AND AT-Y(WS-T) < AT-Y(WS-S) + AT-SH(WS-S)
                 ADD 1 TO WS-BAD
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "atlas no sprite overlaps another or lies outside the atlas" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "atlas more than 128 sprites are kept and the atlas stays within 16384 pixels each way"
         TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF AT-SPRITE-COUNT > 306 AND AT-W <= 16384 AND AT-H <= 16384
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-ATLAS-SIZES.
 COPY CLTEST.
 COPY PACKTEST.
