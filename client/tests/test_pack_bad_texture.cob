*> Edge-case test (spec edge case; FR-012): a texture the client cannot decode makes that sprite fall back to the
*> pack below it, the rest of the pack loads, nothing crashes. Fixture anim: broken.png is not a decodable PNG;
*> animbase below it has a cyan one; flow.png (animated) of the same pack still loads.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PACK-BAD-TEXTURE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/client-test-bad-texture".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 29.
 01 WS-NAMES               PIC X(256) VALUE "animbase anim".
 01 WS-IDS                 PIC X(256) VALUE "file/anim file/animbase".
 01 WS-NAME                PIC X(80).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-SPRITE              BINARY-LONG.
 01 WS-PIXEL               PIC X(32).
 01 WS-E1                  PIC 9.
 01 WS-E2                  PIC 9.
 PROCEDURE DIVISION.
     CALL "TEST-PACK-START" USING CLIENT-STATE WS-DIR WS-DIR-LENGTH WS-NAMES
     CALL "TEST-PACK-ENABLE" USING CLIENT-STATE WS-IDS
     MOVE "anim:block/broken" TO WS-NAME
     MOVE 17 TO WS-NAME-LENGTH
     CALL "TEST-PIXEL" USING CLIENT-STATE WS-NAME WS-NAME-LENGTH WS-PIXEL
     MOVE "bad texture a texture of the top pack that cannot be decoded is the one of the pack below "
         & "(cyan)" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "0,255,255,255" TO TL-EXPECTED
     MOVE WS-PIXEL TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "anim:block/flow" TO WS-NAME
     MOVE 15 TO WS-NAME-LENGTH
     CALL "ATLAS-FIND" USING CLIENT-STATE WS-NAME WS-NAME-LENGTH WS-SPRITE
     MOVE AN-COUNT TO WS-E1
     MOVE 0 TO WS-E2
     IF WS-SPRITE > 0
         MOVE 1 TO WS-E2
     END-IF
     MOVE "bad texture the rest of the pack loads: flow is in the atlas and animated" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING WS-E2 " animations " WS-E1 DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "1 animations 2" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-PACK-BAD-TEXTURE.
 COPY CLTEST.
 COPY PACKTEST.
