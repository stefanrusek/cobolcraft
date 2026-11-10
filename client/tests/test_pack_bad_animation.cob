*> Edge-case test (spec edge case; FR-012): a malformed animation file leaves the sprite static from the pack
*> below and the rest of the pack loads. Fixture anim: bad.png has a malformed bad.png.mcmeta over a two-frame
*> strip, animbase below has a yellow bad.png; oddsize.png (16 x 20, not a multiple of its frame size) has
*> nothing below, so it is the missing texture; flow and mix still animate.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PACK-BAD-ANIMATION.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/client-test-bad-animation".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 30.
 01 WS-NAMES               PIC X(256) VALUE "animbase anim".
 01 WS-IDS                 PIC X(256) VALUE "file/anim file/animbase".
 01 WS-NAME                PIC X(80).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-SPRITE              BINARY-LONG.
 01 WS-PIXEL               PIC X(32).
 01 WS-E1                  PIC 9.
 01 WS-E2                  PIC Z9.
 01 WS-E3                  PIC Z9.
 PROCEDURE DIVISION.
     CALL "TEST-PACK-START" USING CLIENT-STATE WS-DIR WS-DIR-LENGTH WS-NAMES
     CALL "TEST-PACK-ENABLE" USING CLIENT-STATE WS-IDS
     MOVE "anim:block/bad" TO WS-NAME
     MOVE 14 TO WS-NAME-LENGTH
     CALL "ATLAS-FIND" USING CLIENT-STATE WS-NAME WS-NAME-LENGTH WS-SPRITE
     CALL "TEST-PIXEL" USING CLIENT-STATE WS-NAME WS-NAME-LENGTH WS-PIXEL
     MOVE AT-ANIM(WS-SPRITE) TO WS-E1
     MOVE AT-SH(WS-SPRITE) TO WS-E2
     MOVE "bad animation a malformed animation file leaves the sprite static (not animated, 16 high) "
         & "from the pack below (yellow)" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     STRING WS-E1 " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-PIXEL) DELIMITED BY SIZE
         INTO TL-OBSERVED
     MOVE "0 16 255,255,0,255" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "anim:block/oddsize" TO WS-NAME
     MOVE 18 TO WS-NAME-LENGTH
     CALL "ATLAS-FIND" USING CLIENT-STATE WS-NAME WS-NAME-LENGTH WS-SPRITE
     CALL "TEST-PIXEL" USING CLIENT-STATE WS-NAME WS-NAME-LENGTH WS-PIXEL
     MOVE "bad animation an image that is not a multiple of its frame size with no pack below is the "
         & "missing texture (orange)" TO TL-CASE
     MOVE "242,140,40,255" TO TL-EXPECTED
     MOVE WS-PIXEL TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE AN-COUNT TO WS-E2
     MOVE "bad animation the rest of the pack loads: flow and mix animate (2 animations)" TO TL-CASE
     MOVE "2" TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-E2) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-PACK-BAD-ANIMATION.
 COPY CLTEST.
 COPY PACKTEST.
