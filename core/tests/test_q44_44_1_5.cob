*> Corrections to documents 18 to 21 (docs/protocol/44-residual-mob-questions-1-shared-model-framework.md section 5, rows 3, 7 and 11; lane 002-lane-p49i, T22640; phase task T2694). The corrected text
*> of three rows is proven against the code here: row 3 (the item pickup delay constants and setters: the constructor delay is 0, 10 is applied by callers, a thrown item 40; the merge interval 2 or 40
*> and the receiver rule are proven by test_itemphys_41_3 and _4, the friction block lookup at 0.999999 by test_itemphys_41_3), row 7 (TryFindLiquid timer: 22 on a suppressed call, 40 after a search) and
*> row 11 (Brain.tick has four steps and no schedule step). Rows 1, 2 (default equipment tiers and the enchant provider), 5, 6 (the Manhattan scan of the finders), 8 (the EntitySpawnReason matrix), 9
*> (SetHiddenState) and 10 (taming chances) correct text whose rules are the answers RQ-1.1 to RQ-1.4, 1.16, 1.18, 1.23 and 1.27 of section 4 of this document: not built here.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-1-5.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CITEMPHYS.
 01 WS-CASE                PIC X(240).
 01 WS-E                   BINARY-DOUBLE.
 01 WS-O                   BINARY-DOUBLE.
 01 WS-ROW                 BINARY-LONG VALUE 1.
 01 WS-KIND                BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-L1                  BINARY-LONG VALUE 1.
 01 WS-L3                  BINARY-LONG VALUE 3.
 01 WS-NOW                 BINARY-LONG VALUE 100.
 01 WS-NEXT                BINARY-LONG VALUE 120.
 01 WS-SCAN                BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-NAME40              PIC X(40).
 01 WS-I                   BINARY-LONG.
 PROCEDURE DIVISION.
*>   Row 3: the delays.
     MOVE 77 TO EN-DELAY(WS-ROW)
     MOVE IP-SET-DEFAULT-DELAY TO WS-KIND
     CALL "IP-SETUP" USING WS-ROW WS-KIND
     MOVE "row 3: the default pickup delay set by callers is 10" TO WS-CASE
     MOVE 10 TO WS-E
     MOVE EN-DELAY(WS-ROW) TO WS-O
     PERFORM CHECK-N
     MOVE IP-SET-NO-DELAY TO WS-KIND
     CALL "IP-SETUP" USING WS-ROW WS-KIND
     MOVE "row 3: no delay (give command, advancements, dispenser) is 0" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE EN-DELAY(WS-ROW) TO WS-O
     PERFORM CHECK-N
     MOVE IP-SET-NEVER-PICKUP TO WS-KIND
     CALL "IP-SETUP" USING WS-ROW WS-KIND
     MOVE "row 3: never pick up is the infinite 32767" TO WS-CASE
     MOVE 32767 TO WS-E
     MOVE EN-DELAY(WS-ROW) TO WS-O
     PERFORM CHECK-N
     MOVE IP-SET-UNLIMITED-LIFE TO WS-KIND
     CALL "IP-SETUP" USING WS-ROW WS-KIND
     MOVE "row 3: unlimited lifetime is age -32768" TO WS-CASE
     MOVE -32768 TO WS-E
     MOVE EN-AGE(WS-ROW) TO WS-O
     PERFORM CHECK-N
     MOVE IP-SET-EXTENDED-LIFE TO WS-KIND
     CALL "IP-SETUP" USING WS-ROW WS-KIND
     MOVE "row 3: extended lifetime is age -6000 (12000 ticks to live)" TO WS-CASE
     MOVE -6000 TO WS-E
     MOVE EN-AGE(WS-ROW) TO WS-O
     PERFORM CHECK-N
     MOVE IP-SET-FAKE-ITEM TO WS-KIND
     CALL "IP-SETUP" USING WS-ROW WS-KIND
     MOVE "row 3: a fake item is never picked up and has age 5999" TO WS-CASE
     MOVE 5999 TO WS-E
     COMPUTE WS-O = EN-AGE(WS-ROW)
     PERFORM CHECK-N
     MOVE "row 3: a thrown item has the pickup delay 40" TO WS-CASE
     MOVE 40 TO WS-E
     MOVE IP-DELAY-THROWN TO WS-O
     PERFORM CHECK-N
     MOVE "row 3: the dispenser's delay is 0 and the default 10 (constants)" TO WS-CASE
     MOVE 10 TO WS-E
     COMPUTE WS-O = IP-DELAY-DEFAULT + IP-DELAY-DISPENSER
     PERFORM CHECK-N
*>   Row 7: TryFindLiquid timers.
     CALL "Q4-FINDER-TIMER" USING WS-L3 WS-NOW WS-NEXT WS-SCAN WS-NEW
     MOVE "row 7: TryFindLiquid with the timer not expired pushes it to now + 22 and does not scan" TO WS-CASE
     MOVE 22 TO WS-E
     COMPUTE WS-O = WS-NEW - WS-NOW + WS-SCAN * 1000
     PERFORM CHECK-N
     MOVE 130 TO WS-NOW
     CALL "Q4-FINDER-TIMER" USING WS-L3 WS-NOW WS-NEXT WS-SCAN WS-NEW
     MOVE "row 7: TryFindLiquid with the timer expired scans and sets now + 40" TO WS-CASE
     MOVE 1040 TO WS-E
     COMPUTE WS-O = WS-NEW - WS-NOW + WS-SCAN * 1000
     PERFORM CHECK-N
*>   Row 11: Brain.tick.
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         CALL "Q1-BRAIN-STEP" USING WS-I WS-NAME40
         IF WS-NAME40 NOT = SPACES
             ADD 1 TO WS-N
         END-IF
         IF WS-NAME40(1:8) = "schedule"
             ADD 100 TO WS-N
         END-IF
     END-PERFORM
     MOVE "row 11: Brain.tick runs four steps and none of them is a schedule step" TO WS-CASE
     MOVE 4 TO WS-E
     MOVE WS-N TO WS-O
     PERFORM CHECK-N
     MOVE 1 TO WS-I
     CALL "Q1-BRAIN-STEP" USING WS-I WS-NAME40
     MOVE "row 11: the first step is forgetOutdatedMemories (the memory expiry the older text omitted)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-NAME40 = "forgetOutdatedMemories"
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     STOP RUN.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 44-1§5 Corrections to documents 18 to 21: " DELIMITED BY SIZE FUNCTION TRIM(WS-CASE) DELIMITED BY SIZE INTO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-Q44-44-1-5.
