*> Test US14-client (spec 002 FR-035; 17 §5.7 itemBar): the damage bar of a tool at fractions of its durability. ITEM-BAR: no bar for an undamaged
*> stack or no known maximum; width clamp(round(13 - damage x 13 / maximum), 0, 13) and the swatch of the hue (maximum - damage) / maximum / 3
*> (SW-BAR-0 red worn to SW-BAR-0 + 23 green); a stack the server sent with the components damage and max_damage is drawn with a black bar
*> (13 x 2 pixels at (2, 13) of its icon cell) and the coloured part (width x 1) on the layer over the icons; an undamaged one has none.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ITEM-BARS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-DAMAGE              BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-WIDTH               BINARY-LONG.
 01 WS-SWATCH              BINARY-LONG.
 01 WS-CONTAINER           BINARY-LONG VALUE 0.
 01 WS-STATE               BINARY-LONG VALUE 5.
 01 WS-SLOT                BINARY-LONG VALUE 36.
 01 WS-ITEM                BINARY-LONG VALUE 7.
 01 WS-BEFORE              BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-E                   PIC -(5)9.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
*>   damage 0 of 100; 10 of 0 (no maximum); 50 of 1000; 250 of 1000; 500 of 1000; 1000 of 1000; 2000 of 1000 (past the maximum).
     MOVE 0 TO WS-DAMAGE
     MOVE 100 TO WS-MAX
     PERFORM CASE-TEXT
     MOVE 10 TO WS-DAMAGE
     MOVE 0 TO WS-MAX
     PERFORM CASE-TEXT
     MOVE 1000 TO WS-MAX
     MOVE 50 TO WS-DAMAGE
     PERFORM CASE-TEXT
     MOVE 250 TO WS-DAMAGE
     PERFORM CASE-TEXT
     MOVE 500 TO WS-DAMAGE
     PERFORM CASE-TEXT
     MOVE 1000 TO WS-DAMAGE
     PERFORM CASE-TEXT
     MOVE 2000 TO WS-DAMAGE
     PERFORM CASE-TEXT
     MOVE "acceptance US14 17 5.7 bar width and swatch at 0 of 100, a missing maximum, 5%, 25%, 50%, 100% and 200% worn" TO TL-CASE
     MOVE "-1:8 -1:8 12:30 10:25 7:20 0:8 0:8" TO TL-EXPECTED
     MOVE FUNCTION TRIM(TL-OBSERVED) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Drawn: hotbar slot 0 (menu slot 36) holds item 7 with damage 500 of 1000 (the patch carries both components); at 320 x 240 the icon cell
*>   is at (72, 221): the black bar covers GUI (74, 234) to (87, 236), the coloured part 7 pixels wide and 1 high.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     MOVE 640 TO IN-WIN-W
     MOVE 480 TO IN-WIN-H
     MOVE 500 TO WS-DAMAGE
     MOVE 1000 TO WS-MAX
     CALL "TEST-FEED-DAMAGED-SLOT" USING CLIENT-STATE WS-CONN WS-CONTAINER WS-STATE WS-SLOT WS-ITEM WS-DAMAGE WS-MAX
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     CALL "UI-RENDER" USING CLIENT-STATE
     MOVE "N" TO TL-MODE
     MOVE "acceptance US14 a damaged stack draws two bar quads on the layer over the icons (12 vertices)" TO TL-CASE
     MOVE 12 TO TL-EXPECTED-N
     MOVE RL-UT-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-OK
     IF RL-UT-X(1) = 148 AND RL-UT-Y(1) = 468 AND RL-UT-X(3) = 174 AND RL-UT-Y(3) = 472
             AND RL-UT-X(7) = 148 AND RL-UT-Y(7) = 468 AND RL-UT-X(9) = 162 AND RL-UT-Y(9) = 470
         MOVE 1 TO WS-OK
     END-IF
     MOVE "acceptance US14 the black bar is 13 x 2 GUI pixels at (74, 234) and the coloured part 7 x 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The 16 remembered maxima are full after 16 items; a 17th item replaces the last one: item 90 has maximum 40, the 17th (item 106) 80.
     PERFORM VARYING WS-J FROM 90 BY 1 UNTIL WS-J > 106
         COMPUTE WS-MAX = (WS-J - 89) * 40
         MOVE 10 TO WS-DAMAGE
         CALL "TEST-FEED-DAMAGED-SLOT" USING CLIENT-STATE WS-CONN WS-CONTAINER WS-STATE WS-SLOT WS-J WS-DAMAGE WS-MAX
     END-PERFORM
     MOVE 90 TO WS-J
     CALL "ITEM-MAX-DAMAGE" USING CLIENT-STATE WS-J WS-WIDTH
     MOVE 106 TO WS-J
     CALL "ITEM-MAX-DAMAGE" USING CLIENT-STATE WS-J WS-SWATCH
     MOVE "acceptance US14 the maxima of 17 items are kept as 16: item 90 40, the 17th item (106) 680 replacing the 16th" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 40 * 1000 + 680
     COMPUTE TL-OBSERVED-N = WS-WIDTH * 1000 + WS-SWATCH
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 7 TO WS-ITEM
     MOVE 0 TO WS-DAMAGE
     CALL "TEST-FEED-DAMAGED-SLOT" USING CLIENT-STATE WS-CONN WS-CONTAINER WS-STATE WS-SLOT WS-ITEM WS-DAMAGE WS-MAX
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     CALL "UI-RENDER" USING CLIENT-STATE
     MOVE "acceptance US14 an undamaged stack has no bar" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RL-UT-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 CASE-TEXT.
     CALL "ITEM-BAR" USING WS-DAMAGE WS-MAX WS-WIDTH WS-SWATCH
     MOVE WS-WIDTH TO WS-E
     STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-E) ":" DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE WS-SWATCH TO WS-E
     STRING FUNCTION TRIM(TL-OBSERVED) FUNCTION TRIM(WS-E) DELIMITED BY SIZE INTO TL-OBSERVED
     .
 END PROGRAM TEST-ITEM-BARS.

 COPY CLTEST.
