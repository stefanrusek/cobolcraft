*> Acceptance test US18-3 and SC-005 (spec.md User Story 18; 08 §3.2; client/src/packs/stack.cob
*> PACKS-RELOAD): an enabled pack replacing one block state file, model, item definition, texture
*> or lang entry changes only what that file affects; a pack replacing exactly one texture changes
*> exactly the blocks, items, mobs or weather that use it. What the game draws is compared before
*> and after (TEST-DIGEST: atlas sprites, baked block states, item icons, entity images, texts).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US18-OVERRIDE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/client-test-override".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 26.
 01 WS-NAMES               PIC X(256)
     VALUE "ov_texture ov_blockstate ov_model ov_itemdef ov_lang".
 01 WS-IDS                 PIC X(256).
 01 WS-NONE                PIC X(256) VALUE SPACES.
 01 WS-BEFORE              PIC X(67912).
 01 WS-AFTER               PIC X(67912).
 01 WS-TEXT                PIC X(1024).
 01 WS-SCREEN-TEXT         PIC X(1024).
 PROCEDURE DIVISION.
     CALL "TEST-PACK-START" USING CLIENT-STATE WS-DIR WS-DIR-LENGTH WS-NAMES
     CALL "TEST-DIGEST" USING CLIENT-STATE WS-BEFORE
     MOVE "T" TO TL-MODE

     MOVE "file/ov_texture" TO WS-IDS
     PERFORM COMPARE
     MOVE "acceptance US18-3 SC-005 Given an enabled pack replacing exactly one texture (greystone)"
         & " When the game is shown Then exactly the blocks and items that use it change (the "
         & "greystone sprite, block state 2, item 2) and nothing else" TO TL-CASE
     MOVE "sprites cobolcraft:block/greystone states 2 items 2 entities - lang -" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "file/ov_blockstate" TO WS-IDS
     PERFORM COMPARE
     MOVE "acceptance US18-3 Given an enabled pack replacing one block state file (loam -> the "
         & "greystone model) When the game is shown Then only that block's states change" TO TL-CASE
     MOVE "sprites - states 3 items - entities - lang -" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "file/ov_model" TO WS-IDS
     PERFORM COMPARE
     MOVE "acceptance US18-3 Given an enabled pack replacing one model (grit, with the slag "
         & "texture) When the game is shown Then only the block states using it change" TO TL-CASE
     MOVE "sprites - states 5 items - entities - lang -" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "file/ov_itemdef" TO WS-IDS
     PERFORM COMPARE
     MOVE "acceptance US18-3 Given an enabled pack replacing one item definition (trowel -> the "
         & "pry_bar model) When the game is shown Then only that item's icon changes" TO TL-CASE
     MOVE "sprites - states - items 11 entities - lang -" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "file/ov_lang" TO WS-IDS
     PERFORM COMPARE
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-SCREEN-TEXT
     MOVE "acceptance US18-3 Given an enabled pack replacing one language entry When the game is "
         & "shown Then only that text changes (the title screen's Resource Packs button)" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING WS-TEXT DELIMITED BY "  " " / " WS-SCREEN-TEXT DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "sprites - states - items - entities - lang cobolcraft.screen.title.packs / CobolCraft"
         & "|Single-player|Multiplayer|Texture Packs|Quit Game" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   All five enabled change all of it; disabling everything restores the built-in appearance.
     MOVE "file/ov_texture file/ov_blockstate file/ov_model file/ov_itemdef file/ov_lang"
         TO WS-IDS
     PERFORM COMPARE
     MOVE WS-TEXT TO WS-SCREEN-TEXT
     CALL "TEST-PACK-ENABLE" USING CLIENT-STATE WS-NONE
     CALL "TEST-DIGEST" USING CLIENT-STATE WS-AFTER
     CALL "TEST-DIGEST-DIFF" USING WS-BEFORE WS-AFTER WS-TEXT
     MOVE "acceptance US18-3 Given all five packs enabled, then none any more When the game is "
         & "shown Then it first shows every change together, then looks as before" TO TL-CASE
     MOVE "sprites cobolcraft:block/greystone states 2 3 5 items 2 11 entities - lang cobolcraft"
         & ".screen.title.packs / sprites - states - items - entities - lang -" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING WS-SCREEN-TEXT DELIMITED BY "  " " / " WS-TEXT DELIMITED BY "  " INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 COMPARE.
     CALL "TEST-PACK-ENABLE" USING CLIENT-STATE WS-IDS
     CALL "TEST-DIGEST" USING CLIENT-STATE WS-AFTER
     CALL "TEST-DIGEST-DIFF" USING WS-BEFORE WS-AFTER WS-TEXT.
 END PROGRAM ACC-US18-OVERRIDE.
 COPY CLTEST.
 COPY PACKTEST.
