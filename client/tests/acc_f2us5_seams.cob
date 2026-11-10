*> Acceptance test US5-1 (spec 002 FR-011; SC-002; 12 section 2.2, 2.3): the block atlas keeps padding around every
*> sprite so that a mip level of any cell never contains a neighbour's colour: padding = 2^M pixels each side
*> (M the mip level used, 4 for sprites of 16 and 32 pixels: 16 pixels), the padding is the sprite's own edge
*> pixels repeated outward, and the atlas texture has M + 1 levels. Fixture "many": 300 solid sprites of 16
*> pixels and 6 of 32 pixels, each of its own colour.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US5-SEAMS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/client-test-seams".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 23.
 01 WS-NAMES               PIC X(256) VALUE "many".
 01 WS-IDS                 PIC X(256) VALUE "file/many".
 01 WS-S                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-NEG                 BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-CHECKED             BINARY-LONG.
 01 WS-COLOUR              PIC X(4).
 01 WS-E1                  PIC Z(3)9.
 01 WS-E2                  PIC Z(3)9.
 01 B-ATLAS                PIC X(1073741824) BASED.
 PROCEDURE DIVISION.
     CALL "TEST-PACK-START" USING CLIENT-STATE WS-DIR WS-DIR-LENGTH WS-NAMES
     CALL "TEST-PACK-ENABLE" USING CLIENT-STATE WS-IDS
     MOVE AT-PAD TO WS-E1
     MOVE AT-MIPS TO WS-E2
     MOVE "acceptance US5-1 the padding is 16 pixels and the atlas has 5 mip levels for 16 and 32 pixel "
         & "sprites (M = 4)" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "16 5" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Every pixel of every "many" sprite's slot (the sprite and 16 pixels around it) is the sprite's colour.
     SET ADDRESS OF B-ATLAS TO AT-ADDR
     MOVE 0 TO WS-BAD WS-CHECKED
     MOVE AT-PAD TO WS-P
     COMPUTE WS-NEG = 0 - WS-P
     PERFORM VARYING WS-S FROM 2 BY 1 UNTIL WS-S > AT-SPRITE-COUNT
         IF AT-NAME(WS-S)(1:5) = "many:"
             ADD 1 TO WS-CHECKED
             COMPUTE WS-POS = (AT-Y(WS-S) * AT-W + AT-X(WS-S)) * 4 + 1
             MOVE B-ATLAS(WS-POS:4) TO WS-COLOUR
             PERFORM VARYING WS-Y FROM WS-NEG BY 1 UNTIL WS-Y >= AT-SH(WS-S) + WS-P
                 PERFORM VARYING WS-X FROM WS-NEG BY 1 UNTIL WS-X >= AT-SW(WS-S) + WS-P
                     COMPUTE WS-POS = ((AT-Y(WS-S) + WS-Y) * AT-W + AT-X(WS-S) + WS-X) * 4 + 1
                     IF B-ATLAS(WS-POS:4) NOT = WS-COLOUR
                         ADD 1 TO WS-BAD
                     END-IF
                 END-PERFORM
             END-PERFORM
         END-IF
     END-PERFORM
     MOVE "acceptance US5-1 each of the 306 sprites and the 16 pixels around it hold the sprite's own colour "
         & "only (no neighbour bleeds into a mip level)" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N = WS-CHECKED * 1000
     COMPUTE TL-OBSERVED-N = WS-CHECKED * 1000 + WS-BAD
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-F2US5-SEAMS.
 COPY CLTEST.
 COPY PACKTEST.
