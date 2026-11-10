*> Acceptance test US6-4 (spec 002 FR-013, FR-014, FR-015; SC-003; docs/design/builtin-ui-art.md sections 3, 4.1 to 4.9, 5.3,
*> 10): with no pack at all the built-in pack serves the GUI art. It lists the 102 gui sprites, 20 crack overlays, 8 menu images, the
*> pack icon and 15 nine-slice .mcmeta files (240 files with the 94 earlier ones); every image has the size, the number of non-transparent
*> pixels and the SHA-256 of its RGBA that the document gives (the check values of BGUICHK.cpy); the nine-slice metadata is the text of
*> section 3; and the sprites the screens ask for reach the client's GUI sprite rows without any pack (nothing falls back to a swatch).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US6-BUILTIN-ART.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY FORMATS.
 COPY TESTLIB.
 COPY BGUICHK.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-GUI                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-MENU                BINARY-LONG.
 01 WS-ICON                BINARY-LONG.
 01 WS-META                BINARY-LONG.
 01 WS-PATH                PIC X(256).
 01 WS-PATH-LENGTH         BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-IMAGE               PIC X(40000).
 01 WS-CAPACITY            BINARY-LONG VALUE 40000.
 01 WS-W                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-BYTES               BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-HEX                 PIC X(1024).
 01 WS-TEXT                PIC X(1024).
 01 WS-TEXT-LENGTH         BINARY-LONG.
 01 WS-DW                  PIC 999.
 01 WS-DH                  PIC 999.
 01 WS-DNZ                 PIC 99999.
 01 WS-DN                  PIC 9.
 01 WS-DB                  PIC 9.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE 0 TO WS-COUNT WS-GUI WS-BLOCK WS-MENU WS-ICON WS-META
     MOVE 1 TO WS-FOUND
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-FOUND = 0
         CALL "BUILTIN-PATH" USING WS-I WS-PATH WS-PATH-LENGTH WS-FOUND
         IF WS-FOUND = 1
             ADD 1 TO WS-COUNT
             IF WS-PATH(1:38) = "assets/minecraft/textures/gui/sprites/"
                     AND WS-PATH(WS-PATH-LENGTH - 3:4) = ".png"
                 ADD 1 TO WS-GUI
             END-IF
             IF WS-PATH(1:32) = "assets/minecraft/textures/block/"
                 ADD 1 TO WS-BLOCK
             END-IF
             IF WS-PATH(1:29) = "assets/minecraft/textures/gui" AND WS-PATH(30:9) NOT = "/sprites/"
                 ADD 1 TO WS-MENU
             END-IF
             IF WS-PATH(1:39) = "assets/minecraft/textures/misc/unknown_"
                 ADD 1 TO WS-ICON
             END-IF
             IF WS-PATH(WS-PATH-LENGTH - 10:11) = ".png.mcmeta"
                 ADD 1 TO WS-META
             END-IF
         END-IF
     END-PERFORM
     MOVE "acceptance US6-4 the built-in pack lists 240 files, the GUI art after the 94 earlier ones" TO TL-CASE
     MOVE 240 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US6-4 the pack lists 102 gui sprites" TO TL-CASE
     MOVE 102 TO TL-EXPECTED-N
     MOVE WS-GUI TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US6-4 the pack lists 20 crack overlays" TO TL-CASE
     MOVE 20 TO TL-EXPECTED-N
     MOVE WS-BLOCK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US6-4 the pack lists 8 menu images" TO TL-CASE
     MOVE 8 TO TL-EXPECTED-N
     MOVE WS-MENU TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US6-4 the pack lists the pack icon" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-ICON TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US6-4 the pack lists 15 nine-slice .mcmeta files" TO TL-CASE
     MOVE 15 TO TL-EXPECTED-N
     MOVE WS-META TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Every image against the document's size, pixel count and SHA-256.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BC-COUNT
         MOVE SPACES TO WS-PATH
         MOVE BC-PATH(WS-I) TO WS-PATH
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-PATH)) TO WS-PATH-LENGTH
         CALL "BUILTIN-IMAGE" USING WS-PATH WS-PATH-LENGTH WS-IMAGE WS-CAPACITY WS-W WS-H WS-FOUND
         MOVE 0 TO WS-NZ
         MOVE SPACES TO WS-HEX
         IF WS-FOUND = 1
             COMPUTE WS-BYTES = WS-W * WS-H * 4
             PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K >= WS-W * WS-H
                 IF WS-IMAGE(WS-K * 4 + 4:1) NOT = LOW-VALUE
                     ADD 1 TO WS-NZ
                 END-IF
             END-PERFORM
             CALL "SHA256-INIT" USING FMSHA
             CALL "SHA256-UPDATE" USING FMSHA WS-IMAGE WS-BYTES
             CALL "SHA256-FINAL" USING FMSHA FMSHA-DIGEST
             MOVE 32 TO WS-K
             CALL "TEST-HEX-OF" USING FMSHA-DIGEST WS-K WS-HEX
         END-IF
         MOVE SPACES TO TL-CASE
         STRING "acceptance US6-4 the image " FUNCTION TRIM(WS-PATH) " has size, pixels and SHA-256 of the document"
             DELIMITED BY SIZE INTO TL-CASE
         MOVE "T" TO TL-MODE
         MOVE SPACES TO TL-EXPECTED TL-OBSERVED
         STRING BC-W(WS-I) "x" BC-H(WS-I) " " BC-NZ(WS-I) " " BC-SHA(WS-I) DELIMITED BY SIZE INTO TL-EXPECTED
         MOVE WS-W TO WS-DW
         MOVE WS-H TO WS-DH
         MOVE WS-NZ TO WS-DNZ
         STRING WS-DW "x" WS-DH " " WS-DNZ DELIMITED BY SIZE INTO TL-OBSERVED
         IF WS-FOUND = 1
             STRING WS-DW "x" WS-DH " " WS-DNZ " " WS-HEX(1:64) DELIMITED BY SIZE INTO TL-OBSERVED
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM

*>   The nine-slice metadata is exactly the text of section 3.
     MOVE SPACES TO WS-PATH
     MOVE "assets/minecraft/textures/gui/sprites/widget/button_disabled.png.mcmeta" TO WS-PATH
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-PATH)) TO WS-PATH-LENGTH
     MOVE 1024 TO WS-K
     CALL "BUILTIN-READ" USING WS-PATH WS-PATH-LENGTH WS-TEXT WS-K WS-TEXT-LENGTH WS-FOUND
     MOVE "acceptance US6-4 the disabled button's .mcmeta is nine_slice 200 x 20 with border 2" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE '{"gui":{"scaling":{"type":"nine_slice","width":200,"height":20,"border":2}}}' TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     IF WS-FOUND = 1
         MOVE WS-TEXT(1:WS-TEXT-LENGTH) TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO WS-PATH
     MOVE "assets/minecraft/textures/gui/sprites/widget/button.png" TO WS-PATH
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-PATH)) TO WS-PATH-LENGTH
     CALL "BUILTIN-READ" USING WS-PATH WS-PATH-LENGTH WS-TEXT WS-K WS-TEXT-LENGTH WS-FOUND
     MOVE "acceptance US6-4 an image is no JSON file for BUILTIN-READ" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   With no pack the client's GUI sprite rows are the built-in art: the button is the 200 x 20 nine-slice of border 3, the slot 18 x 18.
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "PACK-STACK-INIT" USING CLIENT-STATE
     MOVE 0 TO WS-K
     CALL "GUI-SPRITES-LOAD" USING CLIENT-STATE WS-K
     MOVE "acceptance US6-4 no pack: the button sprite is 200 x 20 nine-slice with border 3" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "200x020 1 3" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE GS-W(GSP-BUTTON) TO WS-DW
     MOVE GS-H(GSP-BUTTON) TO WS-DH
     MOVE GS-NINE(GSP-BUTTON) TO WS-DN
     MOVE GS-BL(GSP-BUTTON) TO WS-DB
     STRING WS-DW "x" WS-DH " " WS-DN " " WS-DB DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US6-4 no pack: the slot sprite is 18 x 18" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 18 TO TL-EXPECTED-N
     MOVE GS-W(GSP-SLOT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-F2US6-BUILTIN-ART.

 COPY CLTEST.
