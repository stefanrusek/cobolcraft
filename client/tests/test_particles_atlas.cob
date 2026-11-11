*> Implementation test of PARTICLE-ATLAS-BUILD (client/src/particles-live.cob; docs/protocol/42-particles-1
*> sections 6.1 to 6.3): the fixture pack "particles" defines crit with two sprites (minecraft:crit, a red
*> 32 x 16 image, and cobolcraft:spark, a blue 16 x 8 image), heart with a sprite no pack has, poof with a
*> definition that is not JSON and sweep_attack with an empty list; the other wired types have no
*> definition. A sprite whose image or definition is missing is the 16 x 16 missing texture. The sprites
*> are stacked in registry order of the wired types (angry_villager 0, cloud 11, crit 13 with two,
*> damage_indicator 14, enchanted_hit 25, explosion 30, heart 55, large_smoke 65, poof 69, smoke 72,
*> white_smoke 73, sneeze 74, spit 75, sweep_attack 77): 13 types of 16 rows and crit of 24, 232 rows, 32 wide.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PARTICLES-ATLAS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.

 01 WS-DIR                 PIC X(64) VALUE "build/client-test-particles".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 27.
 01 WS-NAMES               PIC X(256) VALUE "particles".
 01 WS-IDS                 PIC X(256) VALUE "file/particles".
 01 WS-OFFSET              BINARY-LONG.
 01 WS-PIXEL               PIC X(4).
 01 WS-TEXT                PIC X(1024).
 01 WS-FOUR                BINARY-LONG VALUE 4.
 01 WS-EDIT1               PIC ZZ9.
 01 WS-EDIT2               PIC ZZ9.
 01 WS-EDIT3               PIC ZZ9.
 01 WS-EDIT4               PIC ZZ9.
 01 B-ATLAS                PIC X(1073741824) BASED.
 PROCEDURE DIVISION.
     CALL "TEST-PACK-START" USING CLIENT-STATE WS-DIR WS-DIR-LENGTH WS-NAMES
     CALL "TEST-PACK-ENABLE" USING CLIENT-STATE WS-IDS
     MOVE "test particles atlas the stacked sprites are 32 wide and 232 high, 15 sprites, upload marked"
         TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 32232151 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = PRA-W * 1000000 + PRA-H * 1000 + PRA-SPRITES * 10 + AT-UPLOAD(5)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test particles atlas crit has two sprites of 32 x 16 and 16 x 8 at rows 32 and 48" TO TL-CASE
     MOVE 2321616080 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = PRA-COUNT(14) * 1000000000 + PRA-S-W(PRA-FIRST(14)) * 10000000
         + PRA-S-H(PRA-FIRST(14)) * 100000 + PRA-S-W(PRA-FIRST(14) + 1) * 1000
         + PRA-S-H(PRA-FIRST(14) + 1) * 10
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE PRA-S-Y(PRA-FIRST(14)) TO WS-EDIT1
     MOVE PRA-S-Y(PRA-FIRST(14) + 1) TO WS-EDIT2
     MOVE "test particles atlas the crit sprites start at rows 32 and 48" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "32 48" TO TL-EXPECTED
     STRING FUNCTION TRIM(WS-EDIT1) " " FUNCTION TRIM(WS-EDIT2) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     SET ADDRESS OF B-ATLAS TO PRA-ADDR
     COMPUTE WS-OFFSET = (32 * PRA-W + 31) * 4 + 1
     MOVE B-ATLAS(WS-OFFSET:4) TO WS-PIXEL
     CALL "TEST-HEX-OF" USING WS-PIXEL WS-FOUR WS-TEXT
     MOVE "test particles atlas the red crit image is in the atlas at its last column" TO TL-CASE
     MOVE "c80a0aff" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-OFFSET = (48 * PRA-W + 15) * 4 + 1
     MOVE B-ATLAS(WS-OFFSET:4) TO WS-PIXEL
     CALL "TEST-HEX-OF" USING WS-PIXEL WS-FOUR WS-TEXT
     MOVE "test particles atlas the blue spark image from the cobolcraft namespace is below it" TO TL-CASE
     MOVE "0a0ac8ff" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-OFFSET = (48 * PRA-W + 16) * 4 + 1
     MOVE B-ATLAS(WS-OFFSET:4) TO WS-PIXEL
     CALL "TEST-HEX-OF" USING WS-PIXEL WS-FOUR WS-TEXT
     MOVE "test particles atlas beyond the narrower image the atlas is transparent" TO TL-CASE
     MOVE "00000000" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test particles atlas heart, poof and sweep_attack are one missing 16 x 16 sprite each" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 111161616 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = PRA-COUNT(56) * 100000000 + PRA-COUNT(70) * 10000000
         + PRA-COUNT(78) * 1000000 + PRA-S-W(PRA-FIRST(56)) * 10000 + PRA-S-H(PRA-FIRST(70)) * 100
         + PRA-S-W(PRA-FIRST(78))
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-PARTICLES-ATLAS.
 COPY CLTEST.
 COPY PACKTEST.
