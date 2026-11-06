*> Implementation test of overlays and filters in the pack stack (08 §1.5, §2.4, §3.3;
*> client/src/packs/source.cob, stack.cob): an overlay directory whose format range holds 97.1
*> replaces the pack root's files, one outside it does not; a filter section hides the matching
*> paths (and their .mcmeta companions) of every pack below, the built-in pack too, but not the
*> filtering pack's own files.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PACK-STACK-OVERLAYS-FILTER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/client-test-overlays".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 26.
 01 WS-NAMES               PIC X(256) VALUE "overlay filtered alpha".
 01 WS-IDS                 PIC X(256).
 01 WS-SPRITE              PIC X(80).
 01 WS-SPRITE-LENGTH       BINARY-LONG.
 01 WS-PIXEL               PIC X(32).
 01 WS-LOAM-BEFORE         PIC X(32).
 01 WS-PATH                PIC X(256).
 01 WS-PATH-LENGTH         BINARY-LONG.
 01 WS-PACK                BINARY-LONG.
 01 WS-E1                  PIC Z9.
 01 WS-PTR                 BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-PACK-START" USING CLIENT-STATE WS-DIR WS-DIR-LENGTH WS-NAMES
     MOVE "cobolcraft:block/loam" TO WS-SPRITE
     MOVE 21 TO WS-SPRITE-LENGTH
     CALL "TEST-PIXEL" USING CLIENT-STATE WS-SPRITE WS-SPRITE-LENGTH WS-LOAM-BEFORE

     MOVE "file/overlay" TO WS-IDS
     CALL "TEST-PACK-ENABLE" USING CLIENT-STATE WS-IDS
     MOVE "overlays an active overlay's file replaces the root's; an inactive overlay's files "
         & "are not used (greystone, loam, grit)" TO TL-CASE
     PERFORM SHOW-THREE
     MOVE SPACES TO TL-EXPECTED
     STRING "4,5,6,255|" WS-LOAM-BEFORE DELIMITED BY SPACE "|1,2,3,255" DELIMITED BY SIZE
         INTO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "assets/cobolcraft/textures/block/loam.png.mcmeta" TO WS-PATH
     MOVE 48 TO WS-PATH-LENGTH
     CALL "PACK-RESOLVE" USING CLIENT-STATE WS-PATH WS-PATH-LENGTH WS-PACK
     MOVE "overlays a .mcmeta companion is served like any file" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-PACK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE

*>   filtered (on top) hides cobolcraft textures/block/loam.png and grit.png below it.
     MOVE "file/filtered file/overlay" TO WS-IDS
     CALL "TEST-PACK-ENABLE" USING CLIENT-STATE WS-IDS
     MOVE "filter a filter hides matching files of the packs below (loam of the built-in pack, "
         & "grit of a local pack: the missing texture) but not the filtering pack's own (grit) "
         & "nor files it does not match (greystone)" TO TL-CASE
     PERFORM SHOW-THREE
     MOVE "4,5,6,255|242,140,40,255|9,9,9,255" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "PACK-RESOLVE" USING CLIENT-STATE WS-PATH WS-PATH-LENGTH WS-PACK
     MOVE "filter a .mcmeta companion is hidden with its file" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-PACK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE

*>   A filter only acts on the packs below it.
     MOVE "file/alpha file/filtered" TO WS-IDS
     CALL "TEST-PACK-ENABLE" USING CLIENT-STATE WS-IDS
     MOVE "filter a filtering pack does not hide the files of the packs above it" TO TL-CASE
     PERFORM SHOW-THREE
     MOVE "10,200,10,255|242,140,40,255|9,9,9,255" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 SHOW-THREE.
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     MOVE "cobolcraft:block/greystone" TO WS-SPRITE
     MOVE 26 TO WS-SPRITE-LENGTH
     CALL "TEST-PIXEL" USING CLIENT-STATE WS-SPRITE WS-SPRITE-LENGTH WS-PIXEL
     STRING WS-PIXEL DELIMITED BY SPACE "|" DELIMITED BY SIZE INTO TL-OBSERVED
         WITH POINTER WS-PTR
     MOVE "cobolcraft:block/loam" TO WS-SPRITE
     MOVE 21 TO WS-SPRITE-LENGTH
     CALL "TEST-PIXEL" USING CLIENT-STATE WS-SPRITE WS-SPRITE-LENGTH WS-PIXEL
     STRING WS-PIXEL DELIMITED BY SPACE "|" DELIMITED BY SIZE INTO TL-OBSERVED
         WITH POINTER WS-PTR
     MOVE "cobolcraft:block/grit" TO WS-SPRITE
     MOVE 21 TO WS-SPRITE-LENGTH
     CALL "TEST-PIXEL" USING CLIENT-STATE WS-SPRITE WS-SPRITE-LENGTH WS-PIXEL
     STRING WS-PIXEL DELIMITED BY SPACE INTO TL-OBSERVED WITH POINTER WS-PTR.
 END PROGRAM TEST-PACK-STACK-OVERLAYS-FILTER.
 COPY CLTEST.
 COPY PACKTEST.
