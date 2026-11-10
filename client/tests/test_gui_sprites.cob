*> Implementation test of GUI-SPRITES-LOAD (client/src/packs/gui-sprites.cob): the sprites of the pack stack and
*> their scaling: no pack gives none (GS-W 0); a nine_slice with a number border gives the same border on all sides;
*> one with an object gives each side; a tile scaling and a .mcmeta that is not JSON give a plain stretched sprite.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-GUI-SPRITES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/client-test-gui-sprites".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 29.
 01 WS-NAMES               PIC X(256) VALUE "guipack guisides guitile".
 01 WS-IDS                 PIC X(256).
 01 WS-E                   PIC 9.
 PROCEDURE DIVISION.
     CALL "TEST-PACK-START" USING CLIENT-STATE WS-DIR WS-DIR-LENGTH WS-NAMES
     MOVE "N" TO TL-MODE
     MOVE "gui sprites no pack gives the built-in art: widths 200 and 18" TO TL-CASE
     MOVE 218 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = GS-W(GSP-BUTTON) + GS-W(GSP-SLOT)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "file/guipack" TO WS-IDS
     CALL "TEST-PACK-ENABLE" USING CLIENT-STATE WS-IDS
     MOVE "gui sprites a number border is the border on every side (button 24 x 8, border 3 each)" TO TL-CASE
     MOVE 24813333 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = GS-W(GSP-BUTTON) * 1000000 + GS-H(GSP-BUTTON) * 100000 + GS-NINE(GSP-BUTTON) * 10000
         + GS-BL(GSP-BUTTON) * 1000 + GS-BT(GSP-BUTTON) * 100 + GS-BR(GSP-BUTTON) * 10 + GS-BB(GSP-BUTTON)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "gui sprites a sprite with no .mcmeta is one stretched sprite (slot 18 x 18, no nine-slice)" TO TL-CASE
     MOVE 1800 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = GS-W(GSP-SLOT) * 100 + GS-NINE(GSP-SLOT)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "file/guisides" TO WS-IDS
     CALL "TEST-PACK-ENABLE" USING CLIENT-STATE WS-IDS
     MOVE "gui sprites a .mcmeta without a gui section is a plain sprite (button 8 x 8, no nine-slice)" TO TL-CASE
     MOVE 800 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = GS-W(GSP-BUTTON) * 100 + GS-NINE(GSP-BUTTON)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "gui sprites an object border gives left 1, top 2, right 3, bottom 4" TO TL-CASE
     MOVE 11234 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = GS-NINE(GSP-SLOT) * 10000 + GS-BL(GSP-SLOT) * 1000 + GS-BT(GSP-SLOT) * 100
         + GS-BR(GSP-SLOT) * 10 + GS-BB(GSP-SLOT)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "file/guitile" TO WS-IDS
     CALL "TEST-PACK-ENABLE" USING CLIENT-STATE WS-IDS
     MOVE "gui sprites a tile scaling and a .mcmeta that is not JSON are plain sprites (slot, button 8 x 8)" TO TL-CASE
     MOVE 180800 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = GS-W(GSP-SLOT) * 10000 + GS-NINE(GSP-SLOT) * 1000 + GS-W(GSP-BUTTON) * 100
         + GS-NINE(GSP-BUTTON)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-GUI-SPRITES.

 COPY CLTEST.
 COPY PACKTEST.
