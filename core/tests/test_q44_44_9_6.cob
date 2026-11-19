*> Acceptance test (US15, FR-036; docs/protocol/44-residual-mob-questions-9-end-bosses-decorations.md section 6, lane 002-lane-p49j-a): the display entity rules that are arithmetic: interpolation progress (6.2), the teleport_duration steps and clamp (6.2.1, example 4 ticks to x = 8), the culling flag and render range (6.1) and the text alignment bits (6.3). The core has no display entity.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-9-6.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-NAME                PIC X(240).
 01 WS-EXP                 BINARY-LONG.
 01 WS-OBS                 BINARY-LONG.
 01 WA                      BINARY-LONG.
 01 WB                      BINARY-LONG.
 01 WC                      BINARY-LONG.
 01 WD                      BINARY-LONG.
 01 WE                      BINARY-LONG.
 01 WF1                     FLOAT-LONG.
 01 WF2                     FLOAT-LONG.
 01 WF3                     FLOAT-LONG.
 01 WF4                     FLOAT-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE 5 TO WA
     MOVE 3 TO WB
     MOVE 0 TO WC
     MOVE 0.5 TO WF1
     CALL "Q9-DISPLAY-PROGRESS" USING WA WB WC WF1 WF2
     MOVE "acceptance US15 44-9§6 6.2 duration 0: progress 1" TO WS-NAME
     MOVE 1000 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WF2 * 1000
     PERFORM EXPECT
     MOVE 15 TO WA
     MOVE 10 TO WB
     MOVE 20 TO WC
     MOVE 0.5 TO WF1
     CALL "Q9-DISPLAY-PROGRESS" USING WA WB WC WF1 WF2
     MOVE "acceptance US15 44-9§6 6.2 start tick 10, duration 20, tick 15 partial 0.5: progress 0.275 (x1000)" TO WS-NAME
     MOVE 275 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WF2 * 1000
     PERFORM EXPECT
     MOVE 5 TO WA
     CALL "Q9-DISPLAY-PROGRESS" USING WA WB WC WF1 WF2
     MOVE "acceptance US15 44-9§6 6.2 before the start the progress is clamped to 0" TO WS-NAME
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WF2 * 1000
     PERFORM EXPECT
     MOVE 90 TO WA
     CALL "Q9-DISPLAY-PROGRESS" USING WA WB WC WF1 WF2
     MOVE "acceptance US15 44-9§6 6.2 after the end it is clamped to 1" TO WS-NAME
     MOVE 1000 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WF2 * 1000
     PERFORM EXPECT
     MOVE 0 TO WF1
     MOVE 2 TO WF2
     CALL "Q9-DISPLAY-CULL" USING WF1 WF2 WA
     MOVE "acceptance US15 44-9§6 6.1 width 0: no culling box (noCulling)" TO WS-NAME
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WA
     PERFORM EXPECT
     MOVE 2 TO WF1
     MOVE 0 TO WF2
     CALL "Q9-DISPLAY-CULL" USING WF1 WF2 WA
     MOVE "acceptance US15 44-9§6 6.1 height 0: no culling box" TO WS-NAME
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WA
     PERFORM EXPECT
     MOVE 2 TO WF1
     MOVE 3 TO WF2
     CALL "Q9-DISPLAY-CULL" USING WF1 WF2 WA
     MOVE "acceptance US15 44-9§6 6.1 both set: a culling box exists" TO WS-NAME
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WA
     PERFORM EXPECT
     MOVE 1 TO WF1
     MOVE 1 TO WF2
     MOVE 4000 TO WF3
     CALL "Q9-DISPLAY-RANGE" USING WF1 WF2 WF3 WA
     MOVE "acceptance US15 44-9§6 6.1 view range 1.0, scale 1: visible inside 64 blocks (squared 4000)" TO WS-NAME
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WA
     PERFORM EXPECT
     MOVE 4096 TO WF3
     CALL "Q9-DISPLAY-RANGE" USING WF1 WF2 WF3 WA
     MOVE "acceptance US15 44-9§6 6.1 and not at squared distance 4096 (strict)" TO WS-NAME
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WA
     PERFORM EXPECT
     MOVE 0.5 TO WF1
     MOVE 1100 TO WF3
     CALL "Q9-DISPLAY-RANGE" USING WF1 WF2 WF3 WA
     MOVE "acceptance US15 44-9§6 6.1 view range 0.5 halves the distance (32 blocks: squared 1100 not visible)" TO WS-NAME
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WA
     PERFORM EXPECT
     MOVE 75 TO WA
     CALL "Q9-TELEPORT-CLAMP" USING WA
     MOVE "acceptance US15 44-9§6 6.1 teleport_duration 75 reads back as 59" TO WS-NAME
     MOVE 59 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WA
     PERFORM EXPECT
     MOVE -4 TO WA
     CALL "Q9-TELEPORT-CLAMP" USING WA
     MOVE "acceptance US15 44-9§6 6.1 teleport_duration -4 reads back as 0" TO WS-NAME
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WA
     PERFORM EXPECT
     MOVE 0 TO WF1
     MOVE 8 TO WF2
     MOVE 4 TO WA
     CALL "Q9-TELEPORT-STEP" USING WF1 WF2 WA
     MOVE "acceptance US15 44-9§6 6.2.1 4 ticks, x 0 to 8: tick 1 x = 2" TO WS-NAME
     MOVE 2 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WF1
     PERFORM EXPECT
     CALL "Q9-TELEPORT-STEP" USING WF1 WF2 WA
     MOVE "acceptance US15 44-9§6 6.2.1 tick 2: x = 4" TO WS-NAME
     MOVE 4 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WF1
     PERFORM EXPECT
     CALL "Q9-TELEPORT-STEP" USING WF1 WF2 WA
     MOVE "acceptance US15 44-9§6 6.2.1 tick 3: x = 6" TO WS-NAME
     MOVE 6 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WF1
     PERFORM EXPECT
     CALL "Q9-TELEPORT-STEP" USING WF1 WF2 WA
     MOVE "acceptance US15 44-9§6 6.2.1 tick 4 (t = 1): x = 8" TO WS-NAME
     MOVE 8 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WF1
     PERFORM EXPECT
     CALL "Q9-TELEPORT-STEP" USING WF1 WF2 WA
     MOVE "acceptance US15 44-9§6 6.2.1 no steps left: x stays" TO WS-NAME
     MOVE 8 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WF1
     PERFORM EXPECT
     MOVE 8 TO WA
     CALL "Q9-TEXT-ALIGN" USING WA WB
     MOVE "acceptance US15 44-9§6 6.3 style flags 8: left aligned" TO WS-NAME
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WB
     PERFORM EXPECT
     MOVE 16 TO WA
     CALL "Q9-TEXT-ALIGN" USING WA WB
     MOVE "acceptance US15 44-9§6 6.3 flags 16: right aligned" TO WS-NAME
     MOVE 2 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WB
     PERFORM EXPECT
     MOVE 24 TO WA
     CALL "Q9-TEXT-ALIGN" USING WA WB
     MOVE "acceptance US15 44-9§6 6.3 flags 24 (both): left wins, bit 8 is tested first" TO WS-NAME
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WB
     PERFORM EXPECT
     MOVE 3 TO WA
     CALL "Q9-TEXT-ALIGN" USING WA WB
     MOVE "acceptance US15 44-9§6 6.3 neither (shadow and see-through only, 3): centre" TO WS-NAME
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WB
     PERFORM EXPECT
     STOP RUN.
 EXPECT.
     MOVE WS-NAME TO TL-CASE
     MOVE WS-EXP TO TL-EXPECTED-N
     MOVE WS-OBS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-Q44-44-9-6.
