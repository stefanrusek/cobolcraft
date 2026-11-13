*> Implementation test (002-lane-mobs2, T4140; docs/protocol/12 section 5 experience bar, 05b 0x69 Set Experience): the client keeps the progress, the
*> level and the total of Set Experience; in survival the HUD draws the bar (182 x 5 at ((W - 182) / 2, H - 29), the progress filling (int)(progress x 183)
*> pixels, at most 182) and, from level 1, the level number centred at H - 35; creative draws neither. T4202: the bar is the pack sprites
*> hud/experience_bar_background (a sprite widget) and hud/experience_bar_progress (a clipped sprite, WK-CLIP, w = the filled pixels), and the
*> number is five labels (black is colour 1, #000001, since 0 means the default white): black at (+1, 0), (-1, 0), (0, +1), (0, -1), then #80ff20 at the centre (12 section 5).
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
 01 WS-BLACKS              BINARY-LONG.
 01 WS-BG-X                BINARY-LONG.
 01 WS-LABEL-X             BINARY-LONG.
 01 WS-GREEN-Y             BINARY-LONG.
 01 WS-OFFSETS             PIC X(11).
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
     MOVE WS-GREEN-Y TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test hud xp: the number is outlined by four black copies, one pixel off each way, and one green" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE WS-LABELS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test hud xp: four of the five are black" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE WS-BLACKS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
     MOVE "test hud xp: the black copies are at (+1, 0), (-1, 0), (0, +1), (0, -1) of the green one" TO TL-CASE
     MOVE "+0 -0 0+ 0-" TO TL-EXPECTED
     MOVE WS-OFFSETS TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
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
*>   The background is the sprite widget of GSP-XP-BACK, the progress the clipped sprite of GSP-XP-PROGRESS; the number is five labels of
*>   argument 78 (the four black ones first, the green one last).
     MOVE 0 TO WS-BAR-W WS-BG-W WS-BG-Y WS-BG-X WS-LABEL-Y WS-LABELS WS-BLACKS WS-GREEN-Y WS-LABEL-X
     MOVE SPACES TO WS-LABEL-TEXT WS-OFFSETS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-SPRITE AND SM-W-ARG(WS-I) = GSP-XP-BACK
             MOVE SM-W-W(WS-I) TO WS-BG-W
             MOVE SM-W-Y(WS-I) TO WS-BG-Y
             MOVE SM-W-X(WS-I) TO WS-BG-X
         END-IF
         IF SM-W-KIND(WS-I) = WK-CLIP AND SM-W-ARG(WS-I) = GSP-XP-PROGRESS
             MOVE SM-W-W(WS-I) TO WS-BAR-W
         END-IF
         IF SM-W-KIND(WS-I) = WK-LABEL AND SM-W-ARG(WS-I) = 78
             ADD 1 TO WS-LABELS
             MOVE SM-W-TEXT(WS-I)(1:SM-W-LENGTH(WS-I)) TO WS-LABEL-TEXT
             IF SM-W-COLOUR(WS-I) = 8454176
                 MOVE SM-W-Y(WS-I) TO WS-GREEN-Y
                 MOVE SM-W-X(WS-I) TO WS-LABEL-X
             ELSE
                 ADD 1 TO WS-BLACKS
             END-IF
         END-IF
     END-PERFORM
*>   The offsets of the black copies from the green one (the green one is drawn last, so it is known after the loop).
     MOVE 0 TO WS-BLACKS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-LABEL AND SM-W-ARG(WS-I) = 78 AND SM-W-COLOUR(WS-I) NOT = 8454176
             ADD 1 TO WS-BLACKS
             EVALUATE TRUE
                 WHEN SM-W-X(WS-I) = WS-LABEL-X + 1 AND SM-W-Y(WS-I) = WS-GREEN-Y
                     MOVE "+0" TO WS-OFFSETS(1:2)
                 WHEN SM-W-X(WS-I) = WS-LABEL-X - 1 AND SM-W-Y(WS-I) = WS-GREEN-Y
                     MOVE "-0" TO WS-OFFSETS(4:2)
                 WHEN SM-W-X(WS-I) = WS-LABEL-X AND SM-W-Y(WS-I) = WS-GREEN-Y + 1
                     MOVE "0+" TO WS-OFFSETS(7:2)
                 WHEN SM-W-X(WS-I) = WS-LABEL-X AND SM-W-Y(WS-I) = WS-GREEN-Y - 1
                     MOVE "0-" TO WS-OFFSETS(10:2)
             END-EVALUATE
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
