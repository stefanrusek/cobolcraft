*> Lane bugsunchest (T62200 and on; operator try19 play, screenshots of a closed chest: the lid's top showed a dark recessed rectangle with a lighter border, as
*> if looking into an open chest): the top face of the lid of a closed chest must sample the artwork's plank rectangle (the UP rectangle of the unwrap, texels
*> (u + d + w, v) to (u + d + 2 w, v + d); 52 section 3.3 and open question 1), not the dark rectangle that is the inside of the lid (the DOWN rectangle, texels
*> (u + d, v) to (u + d + w, v + d)). The rectangles of the base are the other way round: its outside bottom is the DOWN rectangle (planks), its inside top is the UP
*> rectangle (black). Reads the generated vanilla pack's chest textures (CC_GENERATED_DIR; the sprite is missing without it and the test fails): the closed chest
*> is baked for every facing, the single, left and right models of the chest and the trapped chest, the ender chest and the copper chest, and the pixel under the
*> centre of the lid's top quad (y 14/16, shade up) is read from the block atlas and compared with the texel of the plank rectangle and with the dark rectangle.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CHEST-LID-TOP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/client-test-chest-lid".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 27.
 01 WS-GEN                 PIC X(1024).
 01 WS-NAME                PIC X(48).
 01 WS-FACING              PIC X(8).
 01 WS-TYPE                PIC X(8).
 01 WS-ID                  PIC X(80).
 01 WS-ID-LENGTH           BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-SPRITE              BINARY-LONG.
 01 WS-CASE-NO             BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-WANT-SHADE          BINARY-LONG.
 01 WS-WANT-Y16            BINARY-LONG.
 01 WS-Y16                 BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-SU                  FLOAT-LONG.
 01 WS-SV                  FLOAT-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-SCALE               BINARY-LONG.
 01 WS-TX                  BINARY-LONG.
 01 WS-INSIDE-X            BINARY-LONG.
 01 WS-HEX                 PIC X(8).
 01 WS-OBSERVED            PIC X(8).
 01 WS-EXPECTED            PIC X(8).
 01 WS-INSIDE              PIC X(8).
 01 WS-DIGITS              PIC X(16) VALUE "0123456789ABCDEF".
 01 WS-B                   BINARY-LONG.
 01 WS-HI                  BINARY-LONG.
 01 WS-LO                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-LABEL               PIC X(60).
 01 WS-EDIT                PIC Z9.
 01 B-ATLAS                PIC X(1073741824) BASED.
 PROCEDURE DIVISION.
     CALL "TEST-SP-START" USING CLIENT-STATE WS-DIR WS-DIR-LENGTH
     MOVE SPACES TO WS-GEN
     ACCEPT WS-GEN FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-GEN = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-GEN
     END-IF
     MOVE SPACES TO CL-GENERATED-DIR
     MOVE WS-GEN TO CL-GENERATED-DIR
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-GEN)) TO CL-GENERATED-DIR-LENGTH
     CALL "PACKS-RELOAD" USING CLIENT-STATE
     MOVE "T" TO TL-MODE

     PERFORM VARYING WS-CASE-NO FROM 1 BY 1 UNTIL WS-CASE-NO > 13
         EVALUATE WS-CASE-NO
             WHEN 1  MOVE "chest" TO WS-NAME MOVE "single" TO WS-TYPE MOVE "south" TO WS-FACING
             WHEN 2  MOVE "chest" TO WS-NAME MOVE "single" TO WS-TYPE MOVE "west" TO WS-FACING
             WHEN 3  MOVE "chest" TO WS-NAME MOVE "single" TO WS-TYPE MOVE "north" TO WS-FACING
             WHEN 4  MOVE "chest" TO WS-NAME MOVE "single" TO WS-TYPE MOVE "east" TO WS-FACING
             WHEN 5  MOVE "chest" TO WS-NAME MOVE "left" TO WS-TYPE MOVE "south" TO WS-FACING
             WHEN 6  MOVE "chest" TO WS-NAME MOVE "right" TO WS-TYPE MOVE "south" TO WS-FACING
             WHEN 7  MOVE "chest" TO WS-NAME MOVE "left" TO WS-TYPE MOVE "west" TO WS-FACING
             WHEN 8  MOVE "trapped_chest" TO WS-NAME MOVE "single" TO WS-TYPE MOVE "north" TO WS-FACING
             WHEN 9  MOVE "trapped_chest" TO WS-NAME MOVE "left" TO WS-TYPE MOVE "south" TO WS-FACING
             WHEN 10 MOVE "trapped_chest" TO WS-NAME MOVE "right" TO WS-TYPE MOVE "east" TO WS-FACING
             WHEN 11 MOVE "ender_chest" TO WS-NAME MOVE "single" TO WS-TYPE MOVE "south" TO WS-FACING
             WHEN 12 MOVE "copper_chest" TO WS-NAME MOVE "single" TO WS-TYPE MOVE "east" TO WS-FACING
             WHEN OTHER MOVE "exposed_copper_chest" TO WS-NAME MOVE "right" TO WS-TYPE MOVE "north" TO WS-FACING
         END-EVALUATE
         CALL "CHEST-BAKE" USING CLIENT-STATE WS-ONE WS-NAME WS-FACING WS-TYPE
         CALL "CHEST-TEXTURE" USING WS-NAME WS-TYPE WS-ZERO WS-ID WS-ID-LENGTH
         CALL "ATLAS-FIND" USING CLIENT-STATE WS-ID WS-ID-LENGTH WS-SPRITE
         MOVE WS-CASE-NO TO WS-EDIT
         MOVE SPACES TO WS-LABEL
         STRING "case " FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-NAME) " " FUNCTION TRIM(WS-TYPE) " " FUNCTION TRIM(WS-FACING)
             DELIMITED BY SIZE INTO WS-LABEL

*>       Texel offsets of the unwrap: a single lid is 14 wide, the halves' 15: the plank rectangle of the lid starts at u + d + w.
         COMPUTE WS-SCALE = AT-SW(WS-SPRITE) / 64
         IF WS-TYPE = "single" OR WS-NAME = "ender_chest"
             MOVE 35 TO WS-TX
             MOVE 21 TO WS-INSIDE-X
         ELSE
             MOVE 36 TO WS-TX
             MOVE 21 TO WS-INSIDE-X
         END-IF

*>       The top of the lid: shade up, y 14/16.
         MOVE DIR-UP TO WS-WANT-SHADE
         MOVE 14 TO WS-WANT-Y16
         PERFORM FIND-QUAD
         MOVE WS-TX TO WS-PX
         MOVE 7 TO WS-PY
         PERFORM EXPECT-TEXEL
         MOVE WS-HEX TO WS-EXPECTED
         MOVE WS-INSIDE-X TO WS-PX
         MOVE 7 TO WS-PY
         PERFORM EXPECT-TEXEL
         MOVE WS-HEX TO WS-INSIDE
         PERFORM SAMPLE-QUAD
         MOVE SPACES TO TL-CASE
         STRING "bugsunchest the lid top of " FUNCTION TRIM(WS-LABEL) " is a quad" DELIMITED BY SIZE INTO TL-CASE
         MOVE "found" TO TL-EXPECTED
         MOVE "missing" TO TL-OBSERVED
         IF WS-FOUND = 1
             MOVE "found" TO TL-OBSERVED
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE SPACES TO TL-CASE
         STRING "bugsunchest the lid top of " FUNCTION TRIM(WS-LABEL) " shows the plank rectangle" DELIMITED BY SIZE INTO TL-CASE
         MOVE WS-EXPECTED TO TL-EXPECTED
         MOVE WS-OBSERVED TO TL-OBSERVED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE SPACES TO TL-CASE
         STRING "bugsunchest the lid top of " FUNCTION TRIM(WS-LABEL) " does not show the dark inside rectangle" DELIMITED BY SIZE
             INTO TL-CASE
         MOVE "other" TO TL-EXPECTED
         MOVE "other" TO TL-OBSERVED
         IF WS-OBSERVED = WS-INSIDE
             MOVE "inside" TO TL-OBSERVED
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>       The underside of the lid (y 9/16, shade down) is the inside rectangle.
         MOVE DIR-DOWN TO WS-WANT-SHADE
         MOVE 9 TO WS-WANT-Y16
         PERFORM FIND-QUAD
         PERFORM SAMPLE-QUAD
         MOVE SPACES TO TL-CASE
         STRING "bugsunchest the lid underside of " FUNCTION TRIM(WS-LABEL) " shows the inside rectangle" DELIMITED BY SIZE
             INTO TL-CASE
         MOVE WS-INSIDE TO TL-EXPECTED
         MOVE WS-OBSERVED TO TL-OBSERVED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>       The bottom of the base (y 0, shade down) is the plank rectangle (14, 19)-(28, 33), centre (21, 26).
         MOVE DIR-DOWN TO WS-WANT-SHADE
         MOVE 0 TO WS-WANT-Y16
         PERFORM FIND-QUAD
         MOVE 21 TO WS-PX
         MOVE 26 TO WS-PY
         PERFORM EXPECT-TEXEL
         MOVE WS-HEX TO WS-EXPECTED
         PERFORM SAMPLE-QUAD
         MOVE SPACES TO TL-CASE
         STRING "bugsunchest the base bottom of " FUNCTION TRIM(WS-LABEL) " shows the plank rectangle" DELIMITED BY SIZE INTO TL-CASE
         MOVE WS-EXPECTED TO TL-EXPECTED
         MOVE WS-OBSERVED TO TL-OBSERVED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     STOP RUN.

*> FIND-QUAD: the quad Q of row 1 with shade WS-WANT-SHADE whose first corner is at WS-WANT-Y16 sixteenths of a block; WS-FOUND 1 when there is one.
 FIND-QUAD.
     MOVE 0 TO WS-FOUND
     MOVE 0 TO WS-Q
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > BM-QUAD-COUNT(1) OR WS-FOUND = 1
         COMPUTE WS-Y16 ROUNDED = BM-Y(1, WS-K, 1) * 16
         IF BM-SHADE(1, WS-K) = WS-WANT-SHADE AND WS-Y16 = WS-WANT-Y16
             MOVE WS-K TO WS-Q
             MOVE 1 TO WS-FOUND
         END-IF
     END-PERFORM.

*> SAMPLE-QUAD: the pixel of the block atlas under the middle of quad WS-Q (a quarter texel in, to stay off texel borders) as hex in WS-OBSERVED.
 SAMPLE-QUAD.
     MOVE "NOQUAD  " TO WS-OBSERVED
     IF WS-FOUND = 1
         COMPUTE WS-SU = (BM-AU(1, WS-Q, 1) + BM-AU(1, WS-Q, 2) + BM-AU(1, WS-Q, 3) + BM-AU(1, WS-Q, 4)) / 4 * AT-W + 0.25
         COMPUTE WS-SV = (BM-AV(1, WS-Q, 1) + BM-AV(1, WS-Q, 2) + BM-AV(1, WS-Q, 3) + BM-AV(1, WS-Q, 4)) / 4 * AT-H + 0.25
         COMPUTE WS-PX = FUNCTION INTEGER(WS-SU)
         COMPUTE WS-PY = FUNCTION INTEGER(WS-SV)
         PERFORM READ-ATLAS-PIXEL
         MOVE WS-HEX TO WS-OBSERVED
     END-IF.

*> EXPECT-TEXEL: the texel (WS-PX, WS-PY) of the 64 x 64 artwork of WS-SPRITE (scaled to the sprite's size) as hex in WS-HEX.
 EXPECT-TEXEL.
     COMPUTE WS-PX = AT-X(WS-SPRITE) + WS-PX * WS-SCALE
     COMPUTE WS-PY = AT-Y(WS-SPRITE) + WS-PY * WS-SCALE
     PERFORM READ-ATLAS-PIXEL.

*> READ-ATLAS-PIXEL: the atlas pixel (WS-PX, WS-PY) as 8 hex digits in WS-HEX.
 READ-ATLAS-PIXEL.
     MOVE "00000000" TO WS-HEX
     SET ADDRESS OF B-ATLAS TO AT-ADDR
     COMPUTE WS-I = (WS-PY * AT-W + WS-PX) * 4
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
         COMPUTE WS-B = FUNCTION ORD(B-ATLAS(WS-I + WS-K:1)) - 1
         COMPUTE WS-HI = WS-B / 16
         COMPUTE WS-LO = WS-B - WS-HI * 16
         MOVE WS-DIGITS(WS-HI + 1:1) TO WS-HEX(WS-K * 2 - 1:1)
         MOVE WS-DIGITS(WS-LO + 1:1) TO WS-HEX(WS-K * 2:1)
     END-PERFORM.
 END PROGRAM TEST-CHEST-LID-TOP.
 COPY CLTEST.
