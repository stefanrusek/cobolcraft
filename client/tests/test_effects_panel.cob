*> Test US14-client (spec 002 T3335/T3336, the inventory half; docs/protocol/49 section 3): the effects panel of the survival inventory screen. x0 = left + 176 + 2,
*> avail = W - x0, shown with at least one effect and avail >= 32 (and then the HUD icons are not drawn); row width avail - 7 from 120 else 32 (compact, no
*> text); stride 33, or 132 div (count - 1) from 6 effects; row j at y = top + j x stride; ascending natural order; the nine-slice background (32 high, bw wide with
*> bw = min(rw, max(32 + name, 32 + duration) + 7)), the 18 x 18 icon at (x0 + 7, y + 7), the name at (x0 + 32, y + 7) and the duration at (x0 + 32, y + 16);
*> the ambient background for an ambient effect; no panel on the crafting bench; with too little room the world HUD's icons are drawn instead.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-EFFECTS-PANEL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-EFFECT              BINARY-LONG.
 01 WS-AMP                 BINARY-LONG VALUE 0.
 01 WS-DUR                 BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 6.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-TEXT                PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-TEXT2               PIC X(256).
 01 WS-NAME-WIDTH          BINARY-LONG.
 01 WS-DUR-WIDTH           BINARY-LONG.
 01 WS-BW                  BINARY-LONG.
 01 WS-RW                  BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-E1                  PIC -(7)9.
 01 WS-E2                  PIC -(7)9.
 01 WS-E3                  PIC -(7)9.
 01 WS-E4                  PIC -(7)9.
 01 WS-E5                  PIC -(7)9.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     MOVE "T" TO TL-MODE
     MOVE 854 TO IN-WIN-W
     MOVE 480 TO IN-WIN-H
     MOVE 0 TO CL-NOW-MS PL-HURT-UNTIL
     MOVE SCR-INVENTORY TO SM-SCREEN
     PERFORM ADD-THREE
     CALL "SCREEN-BUILD" USING CLIENT-STATE

*>   GUI 427 x 240: left 125, x0 303, avail 124, row width 117, stride 33, top 37: poison (600), haste (1200), speed (3600), ascending.
     MOVE GSP-INV-EFFECT-BG TO WS-ROW
     PERFORM SPRITES-OF
     MOVE SPACES TO TL-EXPECTED
     MOVE 1 TO WS-PTR
     MOVE 18 TO WS-EFFECT
     MOVE 600 TO WS-DUR
     MOVE 37 TO WS-Y
     MOVE 117 TO WS-RW
     PERFORM EXPECT-BG
     MOVE 2 TO WS-EFFECT
     MOVE 1200 TO WS-DUR
     MOVE 70 TO WS-Y
     PERFORM EXPECT-BG
     MOVE 0 TO WS-EFFECT
     MOVE 3600 TO WS-DUR
     MOVE 103 TO WS-Y
     PERFORM EXPECT-BG
     MOVE "acceptance US14 49§3.2 three effects: backgrounds (303, 37), (303, 70), (303, 103), 32 high, bw wide, ascending natural order" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     COMPUTE WS-ROW = GSP-MOB-EFFECT-0 + 18
     PERFORM APPEND-SPRITES
     COMPUTE WS-ROW = GSP-MOB-EFFECT-0 + 2
     PERFORM APPEND-SPRITES
     COMPUTE WS-ROW = GSP-MOB-EFFECT-0
     PERFORM APPEND-SPRITES
     MOVE "acceptance US14 49§3.2 the icons are 18 x 18 at (310, y + 7), never faded" TO TL-CASE
     MOVE "310:44:18:18:0 310:77:18:18:0 310:110:18:18:0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The HUD icons are replaced by the panel.
     MOVE GSP-EFFECT-BG TO WS-ROW
     PERFORM SPRITES-OF
     MOVE "acceptance US14 49§2.1 with room for the panel the HUD icons are not drawn" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The texts: the name at (x0 + 32, y + 7) = (335, 44), the duration at (335, 53), row by row.
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-LABEL AND SM-W-X(WS-I) = 335
             MOVE SM-W-Y(WS-I) TO WS-E1
             STRING FUNCTION TRIM(WS-E1) "=" SM-W-TEXT(WS-I)(1:SM-W-LENGTH(WS-I)) " " DELIMITED BY SIZE
                 INTO TL-OBSERVED WITH POINTER WS-PTR
         END-IF
     END-PERFORM
     MOVE "acceptance US14 49§3.2 the name and duration texts at x 335: y 44 Poison, 53 00:30, 77 Haste, 86 01:00, 110 Speed, 119 03:00" TO TL-CASE
     MOVE "44=Poison 53=00:30 77=Haste 86=01:00 110=Speed 119=03:00" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-LABEL AND SM-W-X(WS-I) = 335
             MOVE SM-W-COLOUR(WS-I) TO WS-E1
             STRING FUNCTION TRIM(WS-E1) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
         END-IF
     END-PERFORM
     MOVE "acceptance US14 49§3.3 the names are white (0) and the durations #808080 (8355712)" TO TL-CASE
     MOVE "0 8355712 0 8355712 0 8355712" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   An ambient effect has the ambient background (speed, last in the ascending order: y 103).
     MOVE 0 TO WS-AMP
     MOVE 0 TO WS-EFFECT
     MOVE 3600 TO WS-DUR
     MOVE 7 TO WS-FLAGS
     CALL "EFFECT-SET" USING CLIENT-STATE WS-EFFECT WS-AMP WS-DUR WS-FLAGS
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     MOVE GSP-INV-EFFECT-BG-AMBIENT TO WS-ROW
     PERFORM SPRITES-OF
     MOVE "acceptance US14 49§3.2 an ambient effect has the ambient background (the last row, y 103)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-OBSERVED-N
     IF TL-OBSERVED(1:8) = "303:103:"
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
     MOVE 6 TO WS-FLAGS

*>   Six effects: the stride is 132 div 5 = 26 (rows overlap).
     MOVE 3 TO WS-EFFECT
     PERFORM ADD-ONE
     MOVE 4 TO WS-EFFECT
     PERFORM ADD-ONE
     MOVE 5 TO WS-EFFECT
     PERFORM ADD-ONE
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-SPRITE AND (SM-W-ARG(WS-I) = GSP-INV-EFFECT-BG
                 OR SM-W-ARG(WS-I) = GSP-INV-EFFECT-BG-AMBIENT)
             MOVE SM-W-Y(WS-I) TO WS-E1
             STRING FUNCTION TRIM(WS-E1) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
         END-IF
     END-PERFORM
     MOVE "acceptance US14 49§3.1 six effects: stride 26, rows at 37 63 89 115 141 167" TO TL-CASE
     MOVE "37 63 89 115 141 167" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Compact: GUI 400 wide (window 800): left 112, x0 290, avail 110: 32 wide, no text.
     CALL "EFFECTS-CLEAR" USING CLIENT-STATE
     PERFORM ADD-THREE
     MOVE 800 TO IN-WIN-W
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     MOVE GSP-INV-EFFECT-BG TO WS-ROW
     PERFORM SPRITES-OF
     MOVE "acceptance US14 49§3.1 avail 110 (under 120): compact rows, 32 x 32 at x0 = 290" TO TL-CASE
     MOVE "290:37:32:32:0 290:70:32:32:0 290:103:32:32:0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-LABEL AND SM-W-X(WS-I) = 322
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM
     MOVE "N" TO TL-MODE
     MOVE "acceptance US14 49§3.2 compact rows have no text (bw = 32, avail_text 0)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE

*>   The recipe book open at GUI 379: left 178, x0 356, avail 23 < 32: no panel, the HUD icons are drawn instead.
     MOVE 758 TO IN-WIN-W
     MOVE 1 TO RK-OPEN(1)
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     MOVE GSP-INV-EFFECT-BG TO WS-ROW
     PERFORM SPRITES-OF
     MOVE "acceptance US14 49§3.1 avail 23 (under 32): no panel" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE GSP-EFFECT-BG TO WS-ROW
     PERFORM SPRITES-OF
     MOVE "acceptance US14 49§2.1 the open inventory too narrow for the panel still draws the HUD icons (354, 1), (329, 1), (354, 27)" TO TL-CASE
     MOVE "354:1:24:24:0 329:1:24:24:0 354:27:24:24:0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO RK-OPEN(1)

*>   A long name is clipped to the room of its row (49 section 3.2): Breath of the Nautilus at 100 ticks.
     CALL "EFFECTS-CLEAR" USING CLIENT-STATE
     MOVE 39 TO WS-EFFECT
     MOVE 100 TO WS-DUR
     MOVE 6 TO WS-FLAGS
     CALL "EFFECT-SET" USING CLIENT-STATE WS-EFFECT WS-AMP WS-DUR WS-FLAGS
     MOVE 854 TO IN-WIN-W
     MOVE SCR-INVENTORY TO SM-SCREEN
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-LABEL AND SM-W-X(WS-I) = 335 AND SM-W-Y(WS-I) = 44
             MOVE SM-W-LENGTH(WS-I) TO WS-COUNT
         END-IF
     END-PERFORM
     MOVE "N" TO TL-MODE
     MOVE "acceptance US14 49§3.2 a name wider than the row's room is clipped (shorter than its 22 bytes, not empty)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-COUNT > 0 AND WS-COUNT < 22
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
*>   The crafting bench has no panel.
     MOVE 854 TO IN-WIN-W
     MOVE SCR-BENCH TO SM-SCREEN
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     MOVE GSP-INV-EFFECT-BG TO WS-ROW
     PERFORM SPRITES-OF
     MOVE "acceptance US14 49§3 the crafting bench shows no effects panel" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 ADD-THREE.
     MOVE 6 TO WS-FLAGS
     MOVE 0 TO WS-AMP
     MOVE 0 TO WS-EFFECT
     MOVE 3600 TO WS-DUR
     CALL "EFFECT-SET" USING CLIENT-STATE WS-EFFECT WS-AMP WS-DUR WS-FLAGS
     MOVE 2 TO WS-EFFECT
     MOVE 1200 TO WS-DUR
     CALL "EFFECT-SET" USING CLIENT-STATE WS-EFFECT WS-AMP WS-DUR WS-FLAGS
     MOVE 18 TO WS-EFFECT
     MOVE 600 TO WS-DUR
     CALL "EFFECT-SET" USING CLIENT-STATE WS-EFFECT WS-AMP WS-DUR WS-FLAGS
     .

 ADD-ONE.
     MOVE 5000 TO WS-DUR
     CALL "EFFECT-SET" USING CLIENT-STATE WS-EFFECT WS-AMP WS-DUR WS-FLAGS
     .

*> The expected background of effect WS-EFFECT (duration WS-DUR) at row y WS-Y, row width WS-RW, appended to TL-EXPECTED.
 EXPECT-BG.
     CALL "EFFECT-NAME-TEXT" USING CLIENT-STATE WS-EFFECT WS-AMP WS-TEXT WS-LENGTH
     MOVE WS-TEXT TO WS-TEXT2
     CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-TEXT2 WS-LENGTH WS-NAME-WIDTH
     CALL "EFFECT-DURATION-TEXT" USING CLIENT-STATE WS-DUR WS-TEXT WS-LENGTH
     MOVE WS-TEXT TO WS-TEXT2
     CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-TEXT2 WS-LENGTH WS-DUR-WIDTH
     COMPUTE WS-BW = FUNCTION MIN(WS-RW, FUNCTION MAX(32 + WS-NAME-WIDTH, 32 + WS-DUR-WIDTH) + 7)
     MOVE WS-Y TO WS-E1
     MOVE WS-BW TO WS-E2
     IF WS-PTR > 1
         STRING " " DELIMITED BY SIZE INTO TL-EXPECTED WITH POINTER WS-PTR
     END-IF
     STRING "303:" FUNCTION TRIM(WS-E1) ":" FUNCTION TRIM(WS-E2) ":32:0" DELIMITED BY SIZE INTO TL-EXPECTED
         WITH POINTER WS-PTR
     .

 SPRITES-OF.
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     PERFORM APPEND-SPRITES
     .

*> "x:y:w:h:state" of every sprite widget of row WS-ROW, space separated, appended at WS-PTR.
 APPEND-SPRITES.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-SPRITE AND SM-W-ARG(WS-I) = WS-ROW
             MOVE SM-W-X(WS-I) TO WS-E1
             MOVE SM-W-Y(WS-I) TO WS-E2
             MOVE SM-W-W(WS-I) TO WS-E3
             MOVE SM-W-H(WS-I) TO WS-E4
             MOVE SM-W-STATE(WS-I) TO WS-E5
             IF WS-PTR > 1
                 STRING " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
             END-IF
             STRING FUNCTION TRIM(WS-E1) ":" FUNCTION TRIM(WS-E2) ":" FUNCTION TRIM(WS-E3) ":"
                 FUNCTION TRIM(WS-E4) ":" FUNCTION TRIM(WS-E5) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
         END-IF
     END-PERFORM
     .
 END PROGRAM TEST-EFFECTS-PANEL.

 COPY CLTEST.
