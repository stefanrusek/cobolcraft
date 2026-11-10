*> Implementation test of client/src/packs/font.cob (FONT-LOAD, FONT-GLYPH; 08 §10.10;
*> standin-content §18): the bitmap provider of cobolcraft:default maps code points 32 to 126 to
*> glyph cells of the UI atlas (texture 2) with the advances of §18 (rightmost ink column + 2, 4 for
*> no ink); the font image is copied into the UI atlas unchanged; every other code point (127, any
*> non-ASCII) draws as the missing glyph box, advance 6.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FONT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY TESTLIB.
 01 WS-ADVANCES            PIC X(95) VALUE
     "44566664556646466566666666445666666666666566666666666666666565664666665665555666666656666666456".
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-CP                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-ADVANCE             BINARY-LONG.
 01 WS-OBSERVED            PIC X(95).
 01 WS-DIGIT               PIC 9.
 01 WS-FIXTURE             PIC X(256) VALUE "client/tests/fixtures/textures/ascii.rgba".
 01 WS-REFERENCE           PIC X(24576).
 01 WS-CAPACITY            BINARY-LONG VALUE 24576.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-DIFF                BINARY-LONG.
 01 WS-BOX                 PIC X(8).
 01 WS-INK                 PIC X(4).
 01 B-ATLAS                PIC X(1073741824) BASED.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "PACK-STACK-INIT" USING CLIENT-STATE
     CALL "FONT-LOAD" USING CLIENT-STATE
     CALL "FONT-LOAD" USING CLIENT-STATE
     MOVE SPACES TO WS-OBSERVED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 95
         COMPUTE WS-CP = WS-I + 31
         CALL "FONT-GLYPH" USING CLIENT-STATE WS-CP WS-X WS-Y WS-W WS-H WS-ADVANCE
         MOVE WS-ADVANCE TO WS-DIGIT
         MOVE WS-DIGIT TO WS-OBSERVED(WS-I:1)
     END-PERFORM
     MOVE "font advances of code points 32 to 126 are those of standin-content §18" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE WS-ADVANCES TO TL-EXPECTED
     MOVE WS-OBSERVED TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 65 TO WS-CP
     CALL "FONT-GLYPH" USING CLIENT-STATE WS-CP WS-X WS-Y WS-W WS-H WS-ADVANCE
     MOVE "font A (65) is the 8 x 8 cell at (8, 16) of the UI atlas" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 8160808 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-X * 1000000 + WS-Y * 10000 + WS-W * 100 + WS-H
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The font image sits unchanged at the top-left of the UI atlas: 48 rows of 128 pixels (the atlas is 200 wide).
     CALL "TEST-READ-FILE" USING WS-FIXTURE WS-REFERENCE WS-CAPACITY WS-LENGTH
     SET ADDRESS OF B-ATLAS TO UA-ADDR
     MOVE 0 TO WS-DIFF
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= 48 OR WS-DIFF > 0
         IF B-ATLAS(WS-I * UA-W * 4 + 1:512) NOT = WS-REFERENCE(WS-I * 512 + 1:512)
             MOVE WS-I TO WS-DIFF
             ADD 1 TO WS-DIFF
         END-IF
     END-PERFORM
     MOVE "font the UI atlas is 200 wide (the built-in button) and holds the font image ascii.png pixel for pixel"
         TO TL-CASE
     MOVE 200 TO TL-EXPECTED-N
     MOVE UA-W TO TL-OBSERVED-N
     IF WS-DIFF > 0 OR WS-LENGTH NOT = 24576
         MOVE -1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "font code points 127, 233 and 128512 draw as the missing glyph, advance 6" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "666 same" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE 127 TO WS-CP
     CALL "FONT-GLYPH" USING CLIENT-STATE WS-CP WS-X WS-Y WS-W WS-H WS-ADVANCE
     MOVE WS-X TO WS-I
     MOVE WS-Y TO WS-K
     MOVE WS-ADVANCE TO WS-DIGIT
     MOVE WS-DIGIT TO TL-OBSERVED(1:1)
     MOVE 233 TO WS-CP
     CALL "FONT-GLYPH" USING CLIENT-STATE WS-CP WS-X WS-Y WS-W WS-H WS-ADVANCE
     MOVE WS-ADVANCE TO WS-DIGIT
     MOVE WS-DIGIT TO TL-OBSERVED(2:1)
     MOVE 128512 TO WS-CP
     CALL "FONT-GLYPH" USING CLIENT-STATE WS-CP WS-X WS-Y WS-W WS-H WS-ADVANCE
     MOVE WS-ADVANCE TO WS-DIGIT
     MOVE WS-DIGIT TO TL-OBSERVED(3:1)
     MOVE " differs" TO TL-OBSERVED(4:8)
     IF WS-X = WS-I AND WS-Y = WS-K
         MOVE " same" TO TL-OBSERVED(4:8)
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The missing glyph box F8 88 88 88 88 88 F8 00 in its cell: row 0 ink in columns 0 to 4, row 1
*>   ink in columns 0 and 4, row 7 empty.
     MOVE SPACES TO TL-OBSERVED
     MOVE FUNCTION HEX-TO-CHAR("FFFFFFFF") TO WS-INK
     PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K > 7
         MOVE "........" TO WS-BOX
         PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 7
             COMPUTE WS-DIFF = ((WS-Y + WS-K) * UA-W + WS-X + WS-I) * 4 + 1
             IF B-ATLAS(WS-DIFF:4) = WS-INK
                 MOVE "#" TO WS-BOX(WS-I + 1:1)
             END-IF
         END-PERFORM
         STRING FUNCTION TRIM(TL-OBSERVED) WS-BOX "/" DELIMITED BY SIZE INTO TL-OBSERVED
     END-PERFORM
     MOVE "font the missing glyph cell holds the box glyph of §18" TO TL-CASE
     MOVE "#####.../#...#.../#...#.../#...#.../#...#.../#...#.../#####.../......../"
         TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-FONT.
 COPY CLTEST.
