*> Implementation test of TEXT-FIT and LABELS-WRAPPED (client/src/screens/common.cob; 12 layout rule: no
*> element wider than its room): a fitting text stays; a too wide one is cut at a character boundary and
*> ended with "..."; a text breaks at spaces into labels a line apart, a word wider than the room alone.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-TEXT-FIT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-TEXT                PIC X(512).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-WIDTH               BINARY-LONG.
 01 WS-X                   BINARY-LONG VALUE 7.
 01 WS-Y                   BINARY-LONG VALUE 30.
 01 WS-NEXT                BINARY-LONG.
 01 WS-OBS                 PIC X(200).
 01 WS-DISP                PIC 9.
 01 WS-DISP2               PIC 99.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "PACK-STACK-INIT" USING CLIENT-STATE
     CALL "FONT-LOAD" USING CLIENT-STATE

     MOVE "Ab c" TO WS-TEXT
     MOVE 4 TO WS-LENGTH
     MOVE 100 TO WS-MAX
     CALL "TEXT-FIT" USING CLIENT-STATE WS-TEXT WS-LENGTH WS-MAX
     MOVE "text-fit a text that fits stays as it is" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "Ab c/4" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-LENGTH TO WS-DISP
     STRING WS-TEXT(1:WS-LENGTH) "/" WS-DISP DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "aaaaaaaaaa" TO WS-TEXT
     MOVE 10 TO WS-LENGTH
     MOVE 40 TO WS-MAX
     CALL "TEXT-FIT" USING CLIENT-STATE WS-TEXT WS-LENGTH WS-MAX
     CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-TEXT WS-LENGTH WS-WIDTH
     MOVE "text-fit a too wide text is cut and ended with dots, no wider than the room" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-WIDTH <= 40 AND WS-LENGTH > 3 AND WS-LENGTH < 13 AND WS-TEXT(WS-LENGTH - 2:3) = "..."
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Two-byte characters: never cut between their bytes.
     MOVE ALL X"C3A9" TO WS-TEXT(1:20)
     MOVE 20 TO WS-LENGTH
     MOVE 25 TO WS-MAX
     CALL "TEXT-FIT" USING CLIENT-STATE WS-TEXT WS-LENGTH WS-MAX
     MOVE "text-fit a cut never stops inside a multi-byte character" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-LENGTH > 3 AND FUNCTION MOD(WS-LENGTH - 3, 2) = 0 AND WS-TEXT(WS-LENGTH - 2:3) = "..."
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "abc" TO WS-TEXT
     MOVE 3 TO WS-LENGTH
     MOVE 0 TO WS-MAX
     CALL "TEXT-FIT" USING CLIENT-STATE WS-TEXT WS-LENGTH WS-MAX
     MOVE "text-fit a room too small for any character leaves only the dots" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE ".../3" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-LENGTH TO WS-DISP
     STRING WS-TEXT(1:3) "/" WS-DISP DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Wrapped labels: "aaaa bbbb cc" with room for one word per line.
     MOVE 0 TO SM-WIDGET-COUNT
     MOVE "aaaa bbbb cc" TO WS-TEXT
     MOVE 12 TO WS-LENGTH
     MOVE 30 TO WS-MAX
     CALL "LABELS-WRAPPED" USING CLIENT-STATE WS-TEXT WS-LENGTH WS-X WS-Y WS-MAX WS-NEXT
     MOVE "labels-wrapped words that do not fit together go on lines a font height plus 2 apart" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     MOVE "3|aaaa@30|bbbb" TO TL-EXPECTED
     MOVE SM-WIDGET-COUNT TO WS-DISP
     MOVE SM-W-Y(1) TO WS-DISP2
     STRING WS-DISP "|" SM-W-TEXT(1)(1:4) "@" WS-DISP2 "|" SM-W-TEXT(2)(1:4)
         DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 1 TO TL-EXPECTED-N
     MOVE "labels-wrapped the lines step by the font height plus 2 and the next y is below the last" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-OBSERVED-N
     IF SM-W-Y(2) = 30 + FN-HEIGHT + 2 AND SM-W-Y(3) = 30 + 2 * (FN-HEIGHT + 2)
         AND WS-NEXT = 30 + 3 * (FN-HEIGHT + 2) AND SM-W-X(3) = 7 AND SM-W-TEXT(3)(1:2) = "cc"
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A word wider than the room goes alone; a roomy text stays one line.
     MOVE 0 TO SM-WIDGET-COUNT
     MOVE "aaaaaaaaaa b" TO WS-TEXT
     MOVE 12 TO WS-LENGTH
     CALL "LABELS-WRAPPED" USING CLIENT-STATE WS-TEXT WS-LENGTH WS-X WS-Y WS-MAX WS-NEXT
     MOVE "labels-wrapped a word wider than the room goes alone on its line" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE SM-WIDGET-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 0 TO SM-WIDGET-COUNT
     MOVE 200 TO WS-MAX
     CALL "LABELS-WRAPPED" USING CLIENT-STATE WS-TEXT WS-LENGTH WS-X WS-Y WS-MAX WS-NEXT
     MOVE "labels-wrapped a text with room stays one label" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE SM-WIDGET-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-TEXT-FIT.
