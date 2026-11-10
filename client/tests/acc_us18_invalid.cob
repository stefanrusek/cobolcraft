*> Acceptance test US18-5 (spec.md User Story 18; 08 §1.2, §2.3, §7.1; 08 §10.8.6 packs.error texts;
*> client/src/packs/local.cob, source.cob, stack.cob, screens/pack-select.cob): a pack with invalid
*> metadata or a file the game cannot read shows an error naming the pack and what is wrong, and
*> anything whose appearance cannot be resolved is drawn with the missing-texture stripes.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US18-INVALID.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/client-test-invalid".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 25.
 01 WS-NAMES               PIC X(256) VALUE "badmeta badtex broken.zip nometa.zip".
 01 WS-ACTION              BINARY-LONG.
 01 WS-ARG                 BINARY-LONG.
 01 WS-ANY                 BINARY-LONG VALUE 0.
 01 WS-FOUND               BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-SPRITE              PIC X(80).
 01 WS-SPRITE-LENGTH       BINARY-LONG.
 01 WS-PIXEL               PIC X(32).
 01 WS-PIXEL2              PIC X(32).
 01 WS-PIXEL3              PIC X(32).
 01 WS-E1                  PIC Z9.
 01 WS-POS                 BINARY-LONG.
 01 WS-OP-BEFORE           BINARY-LONG.
 01 WS-COMMAND             PIC X(256).
 PROCEDURE DIVISION.
     CALL "TEST-PACK-START" USING CLIENT-STATE WS-DIR WS-DIR-LENGTH WS-NAMES
*>   Two files of badtex that exist but cannot be opened.
     MOVE LOW-VALUES TO WS-COMMAND
     STRING "chmod 000 build/client-test-invalid/resourcepacks/badtex/assets/cobolcraft/lang/en_"
         "us.json build/client-test-invalid/resourcepacks/badtex/assets/cobolcraft/textures/bloc"
         "k/grit.png" DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE ACT-PACKS TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ANY WS-FOUND
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-TEXT
     MOVE "acceptance US18-5 Given packs with invalid metadata or an unreadable archive When the "
         & "pack screen opens Then each shows an error naming the pack and what is wrong" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "Resource Packs|Selected|Built-in pack|Available|badmeta|badmeta cannot be used: pack."
         & "mcmeta has no usable pack section|badtex|Bad texture pack|Compatible|broken.zip|broken"
         & ".zip cannot be used: the pack cannot be read|nometa.zip|nometa.zip cannot be used: "
         & "pack.mcmeta is missing|Enable|Disable|Move Up|Move Down|Done|Open Pack Folder" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   An unusable pack cannot be enabled.
     MOVE ACT-SELECT TO WS-ACTION
     MOVE 1 TO WS-ARG
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     MOVE ACT-PACK-ENABLE TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ANY WS-FOUND
     MOVE OP-COUNT TO WS-OP-BEFORE

*>   badtex: its greystone.png is broken, its loam.png empty, its grit.png and lang file cannot be
*>   opened, its slag.png (600 x 600) is too large for an atlas sprite.
     MOVE ACT-SELECT TO WS-ACTION
     MOVE 2 TO WS-ARG
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     MOVE ACT-PACK-ENABLE TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ANY WS-FOUND
     MOVE "acceptance US18-5 a pack that cannot be used is not enabled; a usable one is"
         TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-OP-BEFORE TO WS-E1
     STRING FUNCTION TRIM(WS-E1) " " DELIMITED BY SIZE INTO TL-OBSERVED
     IF OP-COUNT > 0
         MOVE SPACES TO WS-TEXT
         STRING TL-OBSERVED DELIMITED BY "  " " " OP-ID(1)(1:OP-ID-LENGTH(1))
             DELIMITED BY SIZE INTO WS-TEXT
         MOVE WS-TEXT TO TL-OBSERVED
     END-IF
     MOVE "0 file/badtex" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE ACT-PACKS-DONE TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ANY WS-FOUND
     MOVE "cobolcraft:block/greystone" TO WS-SPRITE
     MOVE 26 TO WS-SPRITE-LENGTH
     CALL "TEST-PIXEL" USING CLIENT-STATE WS-SPRITE WS-SPRITE-LENGTH WS-PIXEL
     MOVE "cobolcraft:block/loam" TO WS-SPRITE
     MOVE 21 TO WS-SPRITE-LENGTH
     CALL "TEST-PIXEL" USING CLIENT-STATE WS-SPRITE WS-SPRITE-LENGTH WS-PIXEL2
     MOVE "cobolcraft:block/slag" TO WS-SPRITE
     MOVE 21 TO WS-SPRITE-LENGTH
     CALL "TEST-PIXEL" USING CLIENT-STATE WS-SPRITE WS-SPRITE-LENGTH WS-PIXEL3
     MOVE "acceptance US18-5 Given an enabled pack with texture files the game cannot read When "
         & "packs are loaded Then those textures are drawn with the missing-texture stripes"
         TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING WS-PIXEL DELIMITED BY SPACE " " DELIMITED BY SIZE WS-PIXEL2 DELIMITED BY SPACE " "
         DELIMITED BY SIZE WS-PIXEL3 DELIMITED BY SPACE INTO TL-OBSERVED
     MOVE "242,140,40,255 242,140,40,255 242,140,40,255" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE ACT-PACKS TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ANY WS-FOUND
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-TEXT
     MOVE "acceptance US18-5 Given an enabled pack with files the game cannot read When packs "
         & "are loaded Then the pack screen shows errors naming the pack and each file" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE 0 TO WS-POS
     INSPECT WS-TEXT TALLYING WS-POS FOR CHARACTERS BEFORE INITIAL "|Done|"
     MOVE FUNCTION MIN(WS-POS + 2, 1024) TO WS-POS
     MOVE WS-TEXT(WS-POS:) TO TL-OBSERVED
     MOVE "Done|Open Pack Folder|badtex cannot be used: assets/cobolcraft/lang/en_us.json cannot be read|badtex "
         & "cannot be used: assets/cobolcraft/textures/block/greystone.png cannot be read|badtex "
         & "cannot be used: assets/cobolcraft/textures/block/loam.png cannot be read|badtex cannot "
         & "be used: assets/cobolcraft/textures/block/grit.png cannot be read" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-US18-INVALID.
 COPY CLTEST.
 COPY PACKTEST.
