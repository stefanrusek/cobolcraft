*> Acceptance test of docs/protocol/47-default-skin.md (the part of the player model that needs no network): 2.1 the table of 18 default skins, 2.2 the choice by
*> UUID (UUID.hashCode and floorMod 18, every row of the worked examples of section 9 including negative hashes), getDefaultSkin (entry 6, slim steve), 4 the legacy 64 x 32
*> conversion (the twelve mirrored copies of the table checked against the document's source and destination columns, the examples of section 9 and of Validation 4, the hat
*> transparency hack both ways, the opaque base regions, a 64 x 64 image only gets the alpha rules, other sizes are rejected) and 5.1 and 5.3 the seven skin part flags.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-DEFAULT-SKIN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-UUID-TABLE.
    05 FILLER PIC X(38) VALUE "00000000-0000-0000-0000-00000000000000".
    05 FILLER PIC X(38) VALUE "00000000-0000-0001-0000-00000000000001".
    05 FILLER PIC X(38) VALUE "ffffffff-ffff-ffff-ffff-ffffffffffff00".
    05 FILLER PIC X(38) VALUE "069a79f4-44e9-4726-a5be-fca90e38aaf500".
    05 FILLER PIC X(38) VALUE "853c80ef-3c37-49fd-aa49-938b674adae601".
    05 FILLER PIC X(38) VALUE "12345678-1234-5678-9abc-def01234567800".
    05 FILLER PIC X(38) VALUE "5627dd98-e6be-3c21-b8a8-e9234418364111".
    05 FILLER PIC X(38) VALUE "36532b5e-c442-3dbb-a24c-c7e55d0f979a04".
    05 FILLER PIC X(38) VALUE "b50ad385-829d-3141-a216-7e7d7539ba7f04".
    05 FILLER PIC X(38) VALUE "a01e3843-e521-3998-958a-f459800e4d1113".
    05 FILLER PIC X(38) VALUE "a762f560-4fce-3236-812a-b80efff0b62b01".
    05 FILLER PIC X(38) VALUE "f26b062b-3d36-360f-ae4b-690a437fcddf09".
    05 FILLER PIC X(38) VALUE "4d258a81-2358-3084-8166-05b9faccad8002".
 01 WS-UUID-ROWS REDEFINES WS-UUID-TABLE.
    05 WS-UR OCCURS 13 TIMES.
       10 WS-UR-TEXT       PIC X(36).
       10 WS-UR-INDEX      PIC 99.
 01 WS-COPY-TABLE.
    05 FILLER PIC X(18) VALUE "004016020048004004".
    05 FILLER PIC X(18) VALUE "008016024048004004".
    05 FILLER PIC X(18) VALUE "000020024052004012".
    05 FILLER PIC X(18) VALUE "004020020052004012".
    05 FILLER PIC X(18) VALUE "008020016052004012".
    05 FILLER PIC X(18) VALUE "012020028052004012".
    05 FILLER PIC X(18) VALUE "044016036048004004".
    05 FILLER PIC X(18) VALUE "048016040048004004".
    05 FILLER PIC X(18) VALUE "040020040052004012".
    05 FILLER PIC X(18) VALUE "044020036052004012".
    05 FILLER PIC X(18) VALUE "048020032052004012".
    05 FILLER PIC X(18) VALUE "052020044052004012".
 01 WS-COPY-ROWS REDEFINES WS-COPY-TABLE.
    05 WS-CR OCCURS 12 TIMES.
       10 WS-CR-SX         PIC 999.
       10 WS-CR-SY         PIC 999.
       10 WS-CR-DX         PIC 999.
       10 WS-CR-DY         PIC 999.
       10 WS-CR-W          PIC 999.
       10 WS-CR-H          PIC 999.
 01 WS-NAMES-TABLE.
    05 FILLER PIC X(8) VALUE "alex".
    05 FILLER PIC X(8) VALUE "ari".
    05 FILLER PIC X(8) VALUE "efe".
    05 FILLER PIC X(8) VALUE "kai".
    05 FILLER PIC X(8) VALUE "makena".
    05 FILLER PIC X(8) VALUE "noor".
    05 FILLER PIC X(8) VALUE "steve".
    05 FILLER PIC X(8) VALUE "sunny".
    05 FILLER PIC X(8) VALUE "zuri".
 01 WS-NAME-ROWS REDEFINES WS-NAMES-TABLE.
    05 WS-NM                PIC X(8) OCCURS 9 TIMES.
 01 WS-CASE                PIC X(160).
 01 WS-E                   BINARY-LONG.
 01 WS-O                   BINARY-LONG.
 01 WS-HEX                 PIC X(36).
 01 WS-UUID                PIC X(16).
 01 WS-INDEX               BINARY-LONG.
 01 WS-TEXTURE             PIC X(40).
 01 WS-SLIM                BINARY-LONG.
 01 WS-EXPECTED-TEXT       PIC X(40).
 01 WS-IMG                 PIC X(16384).
 01 WS-SAVE                PIC X(16384).
 01 WS-W                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-ROWS                BINARY-LONG.
 01 WS-ALPHA               BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PR                  BINARY-LONG.
 01 WS-PG                  BINARY-LONG.
 01 WS-PB                  BINARY-LONG.
 01 WS-PA                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-DIGIT               BINARY-LONG.
 01 WS-BYTE                BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 01 WS-SRC-X               BINARY-LONG.
 01 WS-SRC-Y               BINARY-LONG.
 01 WS-DST-X               BINARY-LONG.
 01 WS-DST-Y               BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG.
 01 WS-PART                BINARY-LONG.
 01 WS-MASK                BINARY-LONG.
 01 WS-SHOWN               BINARY-LONG.
 01 WS-HI                  BINARY-LONG.
 01 WS-D1                  PIC 999.
 01 WS-D2                  PIC 999.
 PROCEDURE DIVISION.
*>   2.1 the table and 2.2 the entry of every index.
     PERFORM VARYING WS-INDEX FROM 0 BY 1 UNTIL WS-INDEX > 17
         CALL "PLAYER-SKIN-ENTRY" USING WS-INDEX WS-TEXTURE WS-SLIM
         MOVE SPACES TO WS-EXPECTED-TEXT
         IF WS-INDEX < 9
             STRING "entity/player/slim/" FUNCTION TRIM(WS-NM(WS-INDEX + 1)) DELIMITED BY SIZE INTO WS-EXPECTED-TEXT
         ELSE
             STRING "entity/player/wide/" FUNCTION TRIM(WS-NM(WS-INDEX - 8)) DELIMITED BY SIZE INTO WS-EXPECTED-TEXT
         END-IF
         MOVE SPACES TO WS-CASE
         MOVE WS-INDEX TO WS-D1
         STRING "2.1 entry " WS-D1 " texture id" DELIMITED BY SIZE INTO WS-CASE
         MOVE WS-EXPECTED-TEXT TO TL-EXPECTED
         MOVE WS-TEXTURE TO TL-OBSERVED
         PERFORM CHECK-T
         MOVE SPACES TO WS-CASE
         MOVE WS-INDEX TO WS-D1
         STRING "2.1 entry " WS-D1 " is slim for 0 to 8 and wide for 9 to 17" DELIMITED BY SIZE INTO WS-CASE
         MOVE 0 TO WS-E
         IF WS-INDEX < 9
             MOVE 1 TO WS-E
         END-IF
         MOVE WS-SLIM TO WS-O
         PERFORM CHECK-N
     END-PERFORM
     CALL "PLAYER-SKIN-DEFAULT" USING WS-TEXTURE WS-SLIM
     MOVE "2.2 getDefaultSkin is entry 6, slim steve" TO WS-CASE
     MOVE "entity/player/slim/steve" TO TL-EXPECTED
     MOVE WS-TEXTURE TO TL-OBSERVED
     PERFORM CHECK-T
     MOVE "2.2 getDefaultSkin is slim" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-SLIM TO WS-O
     PERFORM CHECK-N
     MOVE -3 TO WS-INDEX
     CALL "PLAYER-SKIN-ENTRY" USING WS-INDEX WS-TEXTURE WS-SLIM
     MOVE "2.1 an index below 0 is entry 6" TO WS-CASE
     MOVE "entity/player/slim/steve" TO TL-EXPECTED
     MOVE WS-TEXTURE TO TL-OBSERVED
     PERFORM CHECK-T
     MOVE 18 TO WS-INDEX
     CALL "PLAYER-SKIN-ENTRY" USING WS-INDEX WS-TEXTURE WS-SLIM
     MOVE "2.1 an index above 17 is entry 6" TO WS-CASE
     MOVE "entity/player/slim/steve" TO TL-EXPECTED
     MOVE WS-TEXTURE TO TL-OBSERVED
     PERFORM CHECK-T
*>   Section 9: the worked examples.
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 13
         MOVE WS-UR-TEXT(WS-K) TO WS-HEX
         PERFORM MAKE-UUID
         CALL "PLAYER-SKIN-FOR-UUID" USING WS-UUID WS-INDEX WS-TEXTURE WS-SLIM
         MOVE SPACES TO WS-CASE
         STRING "9 the skin index of " WS-HEX DELIMITED BY SIZE INTO WS-CASE
         MOVE WS-UR-INDEX(WS-K) TO WS-E
         MOVE WS-INDEX TO WS-O
         PERFORM CHECK-N
         MOVE SPACES TO WS-CASE
         STRING "9 the model of " WS-HEX " follows the index" DELIMITED BY SIZE INTO WS-CASE
         MOVE 0 TO WS-E
         IF WS-UR-INDEX(WS-K) < 9
             MOVE 1 TO WS-E
         END-IF
         MOVE WS-SLIM TO WS-O
         PERFORM CHECK-N
     END-PERFORM
     MOVE "5627dd98-e6be-3c21-b8a8-e92344183641" TO WS-HEX
     PERFORM MAKE-UUID
     CALL "PLAYER-SKIN-FOR-UUID" USING WS-UUID WS-INDEX WS-TEXTURE WS-SLIM
     MOVE "9 default-skin flow: offline Steve gets wide efe" TO WS-CASE
     MOVE "entity/player/wide/efe" TO TL-EXPECTED
     MOVE WS-TEXTURE TO TL-OBSERVED
     PERFORM CHECK-T
*>   4 the legacy conversion. Every pixel encodes its own position (red x, green y, blue 7); the alpha is the stated one.
     MOVE 64 TO WS-W
     MOVE 32 TO WS-H
     MOVE 200 TO WS-ALPHA
     MOVE 32 TO WS-ROWS
     PERFORM FILL-IMAGE
     CALL "PLAYER-SKIN-LEGACY" USING WS-IMG WS-W WS-H WS-STATUS
     MOVE "4 a 64 x 32 skin is accepted" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-STATUS TO WS-O
     PERFORM CHECK-N
     MOVE 36 TO WS-DST-X
     MOVE 48 TO WS-DST-Y
     MOVE 47 TO WS-SRC-X
     MOVE 16 TO WS-SRC-Y
     MOVE "Validation 4 destination (36, 48) is source (47, 16)" TO WS-CASE
     PERFORM CHECK-PIXEL-IS-SOURCE
     MOVE 47 TO WS-DST-X
     MOVE 63 TO WS-DST-Y
     MOVE 52 TO WS-SRC-X
     MOVE 31 TO WS-SRC-Y
     MOVE "Validation 4 destination (47, 63) is source (52, 31)" TO WS-CASE
     PERFORM CHECK-PIXEL-IS-SOURCE
     MOVE 22 TO WS-DST-X
     MOVE 53 TO WS-DST-Y
     MOVE 5 TO WS-SRC-X
     MOVE 21 TO WS-SRC-Y
     MOVE "9 the pixel (5, 21) of the right leg front lands at (22, 53)" TO WS-CASE
     PERFORM CHECK-PIXEL-IS-SOURCE
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J > 11
         PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 3
             COMPUTE WS-DST-X = 44 + WS-I
             COMPUTE WS-DST-Y = 52 + WS-J
             PERFORM GET-DESTINATION
             COMPUTE WS-SRC-X = 55 - WS-I
             COMPUTE WS-SRC-Y = 20 + WS-J
             IF WS-PR NOT = WS-SRC-X OR WS-PG NOT = WS-SRC-Y
                 ADD 1 TO WS-BAD
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "Validation 4 left arm back face (44 + i, 52 + j) is source (55 - i, 20 + j): wrong pixels" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-BAD TO WS-O
     PERFORM CHECK-N
     PERFORM VARYING WS-C FROM 1 BY 1 UNTIL WS-C > 12
         MOVE 0 TO WS-BAD
         PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J >= WS-CR-H(WS-C)
             PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= WS-CR-W(WS-C)
                 COMPUTE WS-DST-X = WS-CR-DX(WS-C) + WS-I
                 COMPUTE WS-DST-Y = WS-CR-DY(WS-C) + WS-J
                 PERFORM GET-DESTINATION
                 COMPUTE WS-SRC-X = WS-CR-SX(WS-C) + WS-CR-W(WS-C) - 1 - WS-I
                 COMPUTE WS-SRC-Y = WS-CR-SY(WS-C) + WS-J
                 IF WS-PR NOT = WS-SRC-X OR WS-PG NOT = WS-SRC-Y OR WS-PB NOT = 7
                     ADD 1 TO WS-BAD
                 END-IF
             END-PERFORM
         END-PERFORM
         MOVE SPACES TO WS-CASE
         MOVE WS-C TO WS-D1
         STRING "4 step 3 row " WS-D1 " is the mirrored copy of its source rectangle: wrong pixels" DELIMITED BY SIZE INTO WS-CASE
         MOVE 0 TO WS-E
         MOVE WS-BAD TO WS-O
         PERFORM CHECK-N
     END-PERFORM
*>   The rows 32 to 63 outside the copies are transparent black; the opacity rules.
     MOVE 0 TO WS-PX
     MOVE 32 TO WS-PY
     MOVE "4 step 3 the new area is transparent black (0, 32): alpha" TO WS-CASE
     MOVE 0 TO WS-E
     PERFORM GET-PIXEL
     MOVE WS-PA TO WS-O
     PERFORM CHECK-N
     MOVE "4 step 3 the new area is transparent black (0, 32): red" TO WS-CASE
     MOVE WS-PR TO WS-O
     PERFORM CHECK-N
     MOVE 10 TO WS-PX
     MOVE 40 TO WS-PY
     MOVE "4 step 3 the jacket rows stay transparent black (10, 40): alpha" TO WS-CASE
     PERFORM GET-PIXEL
     MOVE WS-PA TO WS-O
     PERFORM CHECK-N
     MOVE 10 TO WS-PX
     MOVE 5 TO WS-PY
     MOVE "4a the head base is opaque (10, 5)" TO WS-CASE
     MOVE 255 TO WS-E
     PERFORM GET-PIXEL
     MOVE WS-PA TO WS-O
     PERFORM CHECK-N
     MOVE 40 TO WS-PX
     MOVE 5 TO WS-PY
     MOVE "4b a legacy skin opaque all over the hat area has no hat (40, 5): alpha" TO WS-CASE
     MOVE 0 TO WS-E
     PERFORM GET-PIXEL
     MOVE WS-PA TO WS-O
     PERFORM CHECK-N
     MOVE "4b the hat hack keeps the colour bits (40, 5): red" TO WS-CASE
     MOVE 40 TO WS-E
     MOVE WS-PR TO WS-O
     PERFORM CHECK-N
     MOVE "4b the hat hack keeps the colour bits (40, 5): blue" TO WS-CASE
     MOVE 7 TO WS-E
     MOVE WS-PB TO WS-O
     PERFORM CHECK-N
     MOVE 40 TO WS-PX
     MOVE 20 TO WS-PY
     MOVE "4c the body and arm base (40, 20) is opaque again after the hat hack" TO WS-CASE
     MOVE 255 TO WS-E
     PERFORM GET-PIXEL
     MOVE WS-PA TO WS-O
     PERFORM CHECK-N
     MOVE 30 TO WS-PX
     MOVE 60 TO WS-PY
     MOVE "4d the left leg and arm base (30, 60) is opaque" TO WS-CASE
     PERFORM GET-PIXEL
     MOVE WS-PA TO WS-O
     PERFORM CHECK-N
     MOVE 5 TO WS-PX
     MOVE 50 TO WS-PY
     MOVE "4d the left leg overlay (5, 50) keeps its alpha (0)" TO WS-CASE
     MOVE 0 TO WS-E
     PERFORM GET-PIXEL
     MOVE WS-PA TO WS-O
     PERFORM CHECK-N
     MOVE 55 TO WS-PX
     MOVE 50 TO WS-PY
     MOVE "4d the left arm overlay (55, 50) keeps its alpha (0)" TO WS-CASE
     PERFORM GET-PIXEL
     MOVE WS-PA TO WS-O
     PERFORM CHECK-N
*>   A legacy skin with one see-through pixel in the hat area keeps its hat.
     MOVE 200 TO WS-ALPHA
     MOVE 32 TO WS-ROWS
     PERFORM FILL-IMAGE
     COMPUTE WS-POS = (10 * 64 + 40) * 4 + 4
     MOVE FUNCTION CHAR(101) TO WS-IMG(WS-POS:1)
     CALL "PLAYER-SKIN-LEGACY" USING WS-IMG WS-W WS-H WS-STATUS
     MOVE 45 TO WS-PX
     MOVE 5 TO WS-PY
     MOVE "4b one pixel below alpha 128 keeps the whole hat area (45, 5): alpha stays 200" TO WS-CASE
     MOVE 200 TO WS-E
     PERFORM GET-PIXEL
     MOVE WS-PA TO WS-O
     PERFORM CHECK-N
     MOVE 40 TO WS-PX
     MOVE 10 TO WS-PY
     MOVE "4b the see-through pixel (40, 10) stays alpha 100" TO WS-CASE
     MOVE 100 TO WS-E
     PERFORM GET-PIXEL
     MOVE WS-PA TO WS-O
     PERFORM CHECK-N
*>   A 64 x 64 skin: only the alpha rules, no copies, no hat hack.
     MOVE 64 TO WS-H
     MOVE 0 TO WS-ALPHA
     MOVE 64 TO WS-ROWS
     PERFORM FILL-IMAGE
     MOVE WS-IMG TO WS-SAVE
     COMPUTE WS-POS = (5 * 64 + 40) * 4 + 4
     MOVE FUNCTION CHAR(256) TO WS-IMG(WS-POS:1)
     CALL "PLAYER-SKIN-LEGACY" USING WS-IMG WS-W WS-H WS-STATUS
     MOVE "4 a 64 x 64 skin is accepted" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-STATUS TO WS-O
     PERFORM CHECK-N
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 8
         EVALUATE WS-K
             WHEN 1 MOVE 10 TO WS-PX MOVE 5 TO WS-PY MOVE 255 TO WS-E MOVE "4a 64 x 64: head base (10, 5) opaque" TO WS-CASE
             WHEN 2 MOVE 50 TO WS-PX MOVE 20 TO WS-PY MOVE 255 TO WS-E MOVE "4c 64 x 64: body and arm base (50, 20) opaque" TO WS-CASE
             WHEN 3 MOVE 30 TO WS-PX MOVE 60 TO WS-PY MOVE 255 TO WS-E MOVE "4d 64 x 64: left leg and arm base (30, 60) opaque" TO WS-CASE
             WHEN 4 MOVE 50 TO WS-PX MOVE 5 TO WS-PY MOVE 0 TO WS-E MOVE "4 64 x 64: hat overlay (50, 5) unchanged" TO WS-CASE
             WHEN 5 MOVE 10 TO WS-PX MOVE 40 TO WS-PY MOVE 0 TO WS-E MOVE "4 64 x 64: jacket rows (10, 40) unchanged" TO WS-CASE
             WHEN 6 MOVE 5 TO WS-PX MOVE 50 TO WS-PY MOVE 0 TO WS-E MOVE "4 64 x 64: left pants overlay (5, 50) unchanged" TO WS-CASE
             WHEN 7 MOVE 55 TO WS-PX MOVE 50 TO WS-PY MOVE 0 TO WS-E MOVE "4 64 x 64: left sleeve overlay (55, 50) unchanged" TO WS-CASE
             WHEN OTHER MOVE 40 TO WS-PX MOVE 5 TO WS-PY MOVE 255 TO WS-E MOVE "4 64 x 64: an opaque hat pixel is kept (no hat hack)" TO WS-CASE
         END-EVALUATE
         PERFORM GET-PIXEL
         MOVE WS-PA TO WS-O
         PERFORM CHECK-N
     END-PERFORM
     MOVE 36 TO WS-PX
     MOVE 48 TO WS-PY
     PERFORM GET-PIXEL
     MOVE "4 64 x 64: no copies are made (36, 48) keeps its own red" TO WS-CASE
     MOVE 36 TO WS-E
     MOVE WS-PR TO WS-O
     PERFORM CHECK-N
*>   Other sizes are rejected and the image is untouched.
     MOVE 0 TO WS-ALPHA
     MOVE 32 TO WS-ROWS
     PERFORM FILL-IMAGE
     MOVE WS-IMG TO WS-SAVE
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
         EVALUATE WS-K
             WHEN 1 MOVE 32 TO WS-W MOVE 32 TO WS-H
             WHEN 2 MOVE 64 TO WS-W MOVE 48 TO WS-H
             WHEN 3 MOVE 64 TO WS-W MOVE 16 TO WS-H
             WHEN OTHER MOVE 128 TO WS-W MOVE 64 TO WS-H
         END-EVALUATE
         CALL "PLAYER-SKIN-LEGACY" USING WS-IMG WS-W WS-H WS-STATUS
         MOVE SPACES TO WS-CASE
         MOVE WS-W TO WS-D1
         MOVE WS-H TO WS-D2
         STRING "4 step 1 a " WS-D1 " x " WS-D2 " image is rejected" DELIMITED BY SIZE INTO WS-CASE
         MOVE -1 TO WS-E
         MOVE WS-STATUS TO WS-O
         PERFORM CHECK-N
         MOVE SPACES TO WS-CASE
         MOVE WS-W TO WS-D1
         MOVE WS-H TO WS-D2
         STRING "4 step 1 a " WS-D1 " x " WS-D2 " image is left untouched" DELIMITED BY SIZE INTO WS-CASE
         MOVE WS-SAVE TO TL-EXPECTED
         MOVE WS-IMG TO TL-OBSERVED
         MOVE 0 TO WS-E
         MOVE 0 TO WS-O
         IF WS-SAVE NOT = WS-IMG
             MOVE 1 TO WS-O
         END-IF
         PERFORM CHECK-N
     END-PERFORM
*>   5.1 and 5.3 the seven flags.
     PERFORM VARYING WS-PART FROM 0 BY 1 UNTIL WS-PART > 6
         CALL "PLAYER-PART-MASK" USING WS-PART WS-MASK
         MOVE SPACES TO WS-CASE
         MOVE WS-PART TO WS-D1
         STRING "5.1 mask of part " WS-D1 DELIMITED BY SIZE INTO WS-CASE
         COMPUTE WS-E = 2 ** WS-PART
         MOVE WS-MASK TO WS-O
         PERFORM CHECK-N
         MOVE 127 TO WS-FLAGS
         CALL "PLAYER-PART-SHOWN" USING WS-FLAGS WS-PART WS-SHOWN
         MOVE SPACES TO WS-CASE
         MOVE WS-PART TO WS-D1
         STRING "5.3 with 0x7F part " WS-D1 " is shown" DELIMITED BY SIZE INTO WS-CASE
         MOVE 1 TO WS-E
         MOVE WS-SHOWN TO WS-O
         PERFORM CHECK-N
         MOVE 0 TO WS-FLAGS
         CALL "PLAYER-PART-SHOWN" USING WS-FLAGS WS-PART WS-SHOWN
         MOVE SPACES TO WS-CASE
         MOVE WS-PART TO WS-D1
         STRING "5.3 with the byte 0 part " WS-D1 " is hidden" DELIMITED BY SIZE INTO WS-CASE
         MOVE 0 TO WS-E
         MOVE WS-SHOWN TO WS-O
         PERFORM CHECK-N
         COMPUTE WS-FLAGS = 127 - 2 ** WS-PART
         CALL "PLAYER-PART-SHOWN" USING WS-FLAGS WS-PART WS-SHOWN
         MOVE SPACES TO WS-CASE
         MOVE WS-PART TO WS-D1
         STRING "5.3 toggling off only part " WS-D1 " hides it" DELIMITED BY SIZE INTO WS-CASE
         MOVE WS-SHOWN TO WS-O
         PERFORM CHECK-N
         COMPUTE WS-FLAGS = 2 ** WS-PART
         CALL "PLAYER-PART-SHOWN" USING WS-FLAGS WS-PART WS-SHOWN
         MOVE SPACES TO WS-CASE
         MOVE WS-PART TO WS-D1
         STRING "5.3 the byte with only part " WS-D1 " shows it" DELIMITED BY SIZE INTO WS-CASE
         MOVE 1 TO WS-E
         MOVE WS-SHOWN TO WS-O
         PERFORM CHECK-N
     END-PERFORM
     MOVE 7 TO WS-PART
     CALL "PLAYER-PART-MASK" USING WS-PART WS-MASK
     MOVE "5.1 bit 7 is unused: mask 0" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-MASK TO WS-O
     PERFORM CHECK-N
     MOVE 255 TO WS-FLAGS
     CALL "PLAYER-PART-SHOWN" USING WS-FLAGS WS-PART WS-SHOWN
     MOVE "5.1 an unused part is never shown" TO WS-CASE
     MOVE WS-SHOWN TO WS-O
     PERFORM CHECK-N
     MOVE -1 TO WS-PART
     CALL "PLAYER-PART-MASK" USING WS-PART WS-MASK
     MOVE "5.1 part -1 has mask 0" TO WS-CASE
     MOVE WS-MASK TO WS-O
     PERFORM CHECK-N
     STOP RUN.

 MAKE-UUID.
     MOVE 0 TO WS-J
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
         IF WS-HEX(WS-I:1) NOT = "-"
             COMPUTE WS-BYTE = FUNCTION ORD(WS-HEX(WS-I:1)) - 1
             IF WS-BYTE >= 97
                 COMPUTE WS-DIGIT = WS-BYTE - 87
             ELSE
                 COMPUTE WS-DIGIT = WS-BYTE - 48
             END-IF
             IF FUNCTION MOD(WS-J, 2) = 0
                 COMPUTE WS-POS = WS-J / 2 + 1
                 COMPUTE WS-HI = WS-DIGIT * 16
             ELSE
                 COMPUTE WS-BYTE = WS-HI + WS-DIGIT
                 MOVE FUNCTION CHAR(WS-BYTE + 1) TO WS-UUID(WS-POS:1)
             END-IF
             ADD 1 TO WS-J
         END-IF
     END-PERFORM.

 FILL-IMAGE.
     PERFORM VARYING WS-PY FROM 0 BY 1 UNTIL WS-PY >= WS-ROWS
         PERFORM VARYING WS-PX FROM 0 BY 1 UNTIL WS-PX > 63
             COMPUTE WS-POS = (WS-PY * 64 + WS-PX) * 4 + 1
             MOVE FUNCTION CHAR(WS-PX + 1) TO WS-IMG(WS-POS:1)
             MOVE FUNCTION CHAR(WS-PY + 1) TO WS-IMG(WS-POS + 1:1)
             MOVE FUNCTION CHAR(8) TO WS-IMG(WS-POS + 2:1)
             MOVE FUNCTION CHAR(WS-ALPHA + 1) TO WS-IMG(WS-POS + 3:1)
         END-PERFORM
     END-PERFORM
     IF WS-ROWS < 64
         MOVE LOW-VALUES TO WS-IMG(WS-ROWS * 256 + 1:16384 - WS-ROWS * 256)
     END-IF.

 GET-PIXEL.
     COMPUTE WS-POS = (WS-PY * 64 + WS-PX) * 4 + 1
     COMPUTE WS-PR = FUNCTION ORD(WS-IMG(WS-POS:1)) - 1
     COMPUTE WS-PG = FUNCTION ORD(WS-IMG(WS-POS + 1:1)) - 1
     COMPUTE WS-PB = FUNCTION ORD(WS-IMG(WS-POS + 2:1)) - 1
     COMPUTE WS-PA = FUNCTION ORD(WS-IMG(WS-POS + 3:1)) - 1.

 GET-DESTINATION.
     MOVE WS-DST-X TO WS-PX
     MOVE WS-DST-Y TO WS-PY
     PERFORM GET-PIXEL.

 CHECK-PIXEL-IS-SOURCE.
     PERFORM GET-DESTINATION
     MOVE 0 TO WS-E
     MOVE 0 TO WS-O
     IF WS-PR NOT = WS-SRC-X OR WS-PG NOT = WS-SRC-Y
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N.

 CHECK-N.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 47: " FUNCTION TRIM(WS-CASE) DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-T.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 47: " FUNCTION TRIM(WS-CASE) DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-DEFAULT-SKIN.
