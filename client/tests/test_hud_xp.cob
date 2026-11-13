*> Implementation test (002-lane-mobs2, T4140; docs/protocol/12 section 5 experience bar, 05b 0x69 Set Experience): the client keeps the progress, the
*> level and the total of Set Experience; in survival the HUD draws the bar (182 x 5 at ((W - 182) / 2, H - 29), the progress filling (int)(progress x 183)
*> pixels, at most 182) and, from level 1, the level number centred at H - 35; creative draws neither.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-HUD-XP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-PROGRESS            FLOAT-SHORT.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-BAR-W               BINARY-LONG.
 01 WS-BG-W                BINARY-LONG.
 01 WS-BG-Y                BINARY-LONG.
 01 WS-LABEL-Y             BINARY-LONG.
 01 WS-LABEL-TEXT          PIC X(16).
 01 WS-LABELS              BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE 0.5 TO WS-PROGRESS
     MOVE 7 TO WS-LEVEL
     MOVE 120 TO WS-TOTAL
     CALL "TEST-SET-EXPERIENCE" USING CLIENT-STATE WS-CONN WS-PROGRESS WS-LEVEL WS-TOTAL
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE "N" TO TL-MODE
     MOVE "test hud xp: the level of Set Experience is kept" TO TL-CASE
     MOVE 7 TO TL-EXPECTED-N
     MOVE PL-XP-LEVEL TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test hud xp: the total is kept" TO TL-CASE
     MOVE 120 TO TL-EXPECTED-N
     MOVE PL-XP-TOTAL TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM FIND-WIDGETS
     MOVE "test hud xp: the bar background is 182 wide" TO TL-CASE
     MOVE 182 TO TL-EXPECTED-N
     MOVE WS-BG-W TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test hud xp: progress 0.5 fills (int)(0.5 x 183) = 91 pixels" TO TL-CASE
     MOVE 91 TO TL-EXPECTED-N
     MOVE WS-BAR-W TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test hud xp: the level number is 7" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "7" TO TL-EXPECTED
     MOVE WS-LABEL-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE "test hud xp: the level number is at H - 35, 6 above the bar" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-BG-Y - 6
     MOVE WS-LABEL-Y TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A full bar and no level: the fill stops at 182 and no number is drawn.
     MOVE 1.0 TO WS-PROGRESS
     MOVE 0 TO WS-LEVEL
     CALL "TEST-SET-EXPERIENCE" USING CLIENT-STATE WS-CONN WS-PROGRESS WS-LEVEL WS-TOTAL
     CALL "TEST-STEP" USING CLIENT-STATE
     PERFORM FIND-WIDGETS
     MOVE "test hud xp: a full bar is 182 pixels, not 183" TO TL-CASE
     MOVE 182 TO TL-EXPECTED-N
     MOVE WS-BAR-W TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test hud xp: no level number at level 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-LABELS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Creative: no bar.
     MOVE 1 TO PL-MODE
     CALL "TEST-STEP" USING CLIENT-STATE
     PERFORM FIND-WIDGETS
     MOVE "test hud xp: creative has no experience bar" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BG-W TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 FIND-WIDGETS.
*>   The experience overlays are the widgets of height 5: the first is the background (black swatch), the second the progress (white swatch).
     MOVE 0 TO WS-BAR-W WS-BG-W WS-BG-Y WS-LABEL-Y WS-LABELS
     MOVE SPACES TO WS-LABEL-TEXT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-OVERLAY AND SM-W-H(WS-I) = 5
             IF SM-W-ARG(WS-I) = SW-BLACK
                 MOVE SM-W-W(WS-I) TO WS-BG-W
                 MOVE SM-W-Y(WS-I) TO WS-BG-Y
             ELSE
                 MOVE SM-W-W(WS-I) TO WS-BAR-W
             END-IF
         END-IF
         IF SM-W-KIND(WS-I) = WK-LABEL AND SM-W-ARG(WS-I) = 78
             ADD 1 TO WS-LABELS
             MOVE SM-W-TEXT(WS-I)(1:SM-W-LENGTH(WS-I)) TO WS-LABEL-TEXT
             MOVE SM-W-Y(WS-I) TO WS-LABEL-Y
         END-IF
     END-PERFORM.
 END PROGRAM TEST-HUD-XP.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SET-EXPERIENCE.
*> USING CLIENT-STATE, connection, progress (FLOAT-SHORT), level, total (BINARY-LONG): hands PROTO-PACKET a Set Experience (0x69).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-PACKET              BINARY-LONG VALUE 105.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-CONN                 BINARY-LONG.
 01 L-PROGRESS             FLOAT-SHORT.
 01 L-LEVEL                BINARY-LONG.
 01 L-TOTAL                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-CONN L-PROGRESS L-LEVEL L-TOTAL.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-FLOAT" USING PB-BUFFER L-PROGRESS
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-LEVEL
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-TOTAL
     MOVE 0 TO PB-POS
     CALL "PROTO-PACKET" USING CLIENT-STATE L-CONN PB-BUFFER WS-PACKET
     GOBACK.
 END PROGRAM TEST-SET-EXPERIENCE.
 COPY CLTEST.
