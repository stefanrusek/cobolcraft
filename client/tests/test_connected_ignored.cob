*> Edge-case test (spec edge case; FR-010): connected-texture rules the game does not support (OptiFine ctm and
*> cit properties, MCPatcher ctm, a Continuity model loader) are ignored without error: the pack loads with no pack
*> error and its ordinary textures are in the atlas. Fixture ctm.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CONNECTED-IGNORED.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/client-test-ctm".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 21.
 01 WS-NAMES               PIC X(256) VALUE "ctm".
 01 WS-IDS                 PIC X(256) VALUE "file/ctm".
 01 WS-NAME                PIC X(80).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-PIXEL               PIC X(32).
 01 WS-E1                  PIC 9.
 PROCEDURE DIVISION.
     CALL "TEST-PACK-START" USING CLIENT-STATE WS-DIR WS-DIR-LENGTH WS-NAMES
     CALL "TEST-PACK-ENABLE" USING CLIENT-STATE WS-IDS
     MOVE "ctm:block/after_ctm" TO WS-NAME
     MOVE 19 TO WS-NAME-LENGTH
     CALL "TEST-PIXEL" USING CLIENT-STATE WS-NAME WS-NAME-LENGTH WS-PIXEL
     MOVE PK-ERROR-COUNT TO WS-E1
     MOVE "connected textures a pack with ctm, cit and continuity files loads with no error and its "
         & "textures are used" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     STRING WS-E1 " " FUNCTION TRIM(WS-PIXEL) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "0 11,22,33,255" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-CONNECTED-IGNORED.
 COPY CLTEST.
 COPY PACKTEST.
