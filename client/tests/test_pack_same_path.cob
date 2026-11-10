*> Edge-case test (spec edge case; FR-010): two packs supplying the same path, the higher pack in the stack wins
*> (08 section 3.2): alpha and beta.zip both have cobolcraft:block/greystone (green and blue); with beta
*> enabled above alpha the sprite is blue, with alpha above beta it is green.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PACK-SAME-PATH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/client-test-same-path".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 27.
 01 WS-NAMES               PIC X(256) VALUE "alpha beta.zip".
 01 WS-IDS-A               PIC X(256) VALUE "file/beta.zip file/alpha".
 01 WS-IDS-B               PIC X(256) VALUE "file/alpha file/beta.zip".
 01 WS-NAME                PIC X(80) VALUE "cobolcraft:block/greystone".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 26.
 01 WS-PIXEL               PIC X(32).
 PROCEDURE DIVISION.
     CALL "TEST-PACK-START" USING CLIENT-STATE WS-DIR WS-DIR-LENGTH WS-NAMES
     CALL "TEST-PACK-ENABLE" USING CLIENT-STATE WS-IDS-A
     CALL "TEST-PIXEL" USING CLIENT-STATE WS-NAME WS-NAME-LENGTH WS-PIXEL
     MOVE "same path beta.zip enabled above alpha: its greystone (blue) wins" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "10,10,200,255" TO TL-EXPECTED
     MOVE WS-PIXEL TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-PACK-ENABLE" USING CLIENT-STATE WS-IDS-B
     CALL "TEST-PIXEL" USING CLIENT-STATE WS-NAME WS-NAME-LENGTH WS-PIXEL
     MOVE "same path alpha enabled above beta.zip: its greystone (green) wins" TO TL-CASE
     MOVE "10,200,10,255" TO TL-EXPECTED
     MOVE WS-PIXEL TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-PACK-SAME-PATH.
 COPY CLTEST.
 COPY PACKTEST.
