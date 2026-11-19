*> Acceptance test of docs/protocol/44-residual-mob-questions-8-vehicles-and-projectiles.md section 9 as rule functions (lane 002-lane-p49j-b, T24200 range): the wither skull (inertia, resistance, hit damage and healing, the Wither effect by difficulty) and the large fireball fire and radius rules.

*> The functions of core/src/q44-44-8.cob are not called by a tick (no entity engine for them yet, see the lane task list).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-8-9-RULES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-CASE                PIC X(160).
 01 WS-EXP                 BINARY-LONG.
 01 WS-OBS                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-A                  FLOAT-LONG.
 01 WS-B                  FLOAT-LONG.
 01 WS-C                  FLOAT-LONG.
 01 WS-D                  FLOAT-LONG.
 01 WS-E                  FLOAT-LONG.
 01 WS-F                  FLOAT-LONG.
 01 WS-G                  FLOAT-LONG.
 01 WS-H                  FLOAT-LONG.
 01 WS-J                  FLOAT-LONG.
 01 WS-K                  FLOAT-LONG.
 01 WS-N1                 BINARY-LONG.
 01 WS-N2                 BINARY-LONG.
 01 WS-N3                 BINARY-LONG.
 01 WS-N4                 BINARY-LONG.
 01 WS-N5                 BINARY-LONG.
 01 WS-N6                 BINARY-LONG.
 01 WS-N7                 BINARY-LONG.
 01 WS-N8                 BINARY-LONG.
 01 WS-N9                 BINARY-LONG.
 01 WS-N10                 BINARY-LONG.
 01 WS-N11                 BINARY-LONG.
 01 WS-N12                 BINARY-LONG.
 01 WS-CHAIN.
    05 WS-LEVEL OCCURS 5 TIMES.
       10 WS-AMP            BINARY-LONG.
       10 WS-DUR            BINARY-LONG.
       10 WS-ACTIVE         BINARY-LONG.
 01 WS-TAB.
    05 WS-TN                BINARY-LONG.
    05 WS-TC OCCURS 6 TIMES.
       10 WS-TA             BINARY-LONG.
       10 WS-TB             BINARY-LONG.
       10 WS-TD             BINARY-LONG.
 01 WS-COL.
    05 WS-CELL OCCURS 14 TIMES.
       10 WS-CE             BINARY-LONG.
       10 WS-CF             BINARY-LONG.
 01 WS-S1                  PIC X(32).
 01 WS-S2                  PIC X(32).
 01 WS-S3                  PIC X(32).
 01 WS-S4                  PIC X(32).
 01 WS-S5                  PIC X(32).
 01 WS-S6                  PIC X(32).
 PROCEDURE DIVISION.
     MOVE 1 TO WS-N1
     CALL "Q8-SKULL-INERTIA" USING WS-N1 WS-A
     MOVE "acceptance US15 44-8§9 9 wither skull inertia 0.73 when dangerous" TO WS-CASE
     MOVE 730 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-A * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     CALL "Q8-SKULL-INERTIA" USING WS-N1 WS-A
     MOVE "acceptance US15 44-8§9 9 and 0.95 otherwise" TO WS-CASE
     MOVE 950 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-A * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 3 TO WS-A
     CALL "Q8-SKULL-RESIST" USING WS-N1 WS-N2 WS-A WS-B
     MOVE "acceptance US15 44-8§9 9 a dangerous skull against a destroyable block: min(0.8, 3.0) = 0.8" TO WS-CASE
     MOVE 800 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-B * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 0.5 TO WS-A
     CALL "Q8-SKULL-RESIST" USING WS-N1 WS-N2 WS-A WS-B
     MOVE "acceptance US15 44-8§9 9 a weak block keeps its own resistance (0.5)" TO WS-CASE
     MOVE 500 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-B * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 3 TO WS-A
     CALL "Q8-SKULL-RESIST" USING WS-N1 WS-N2 WS-A WS-B
     MOVE "acceptance US15 44-8§9 9 not dangerous: the base resistance" TO WS-CASE
     MOVE 3000 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-B * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 3 TO WS-A
     CALL "Q8-SKULL-RESIST" USING WS-N1 WS-N2 WS-A WS-B
     MOVE "acceptance US15 44-8§9 9 a block the wither cannot destroy: the base resistance" TO WS-CASE
     MOVE 3000 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-B * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 1 TO WS-N2
     CALL "Q8-SKULL-HIT" USING WS-N1 WS-N2 WS-A WS-B WS-N3
     MOVE "acceptance US15 44-8§9 9 skull with a living owner: 8.0 damage" TO WS-CASE
     MOVE 8000 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-A * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-8§9 9 a surviving target gets the post-attack effects" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N3
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-8§9 9 and the owner does not heal" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-B * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 0 TO WS-N2
     CALL "Q8-SKULL-HIT" USING WS-N1 WS-N2 WS-A WS-B WS-N3
     MOVE "acceptance US15 44-8§9 9 a killed target heals the owner 5.0" TO WS-CASE
     MOVE 5000 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-B * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-8§9 9 and gets no post-attack effects" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N3
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 1 TO WS-N2
     CALL "Q8-SKULL-HIT" USING WS-N1 WS-N2 WS-A WS-B WS-N3
     MOVE "acceptance US15 44-8§9 9 without a living owner: 5.0 magic damage" TO WS-CASE
     MOVE 5000 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-A * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     CALL "Q8-SKULL-WITHER" USING WS-N1 WS-N2 WS-N3
     MOVE "acceptance US15 44-8§9 9 Wither effect on difficulty 0 lasts 0 ticks" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N2
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     CALL "Q8-SKULL-WITHER" USING WS-N1 WS-N2 WS-N3
     MOVE "acceptance US15 44-8§9 9 Wither effect on difficulty 1 lasts 0 ticks" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N2
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 2 TO WS-N1
     CALL "Q8-SKULL-WITHER" USING WS-N1 WS-N2 WS-N3
     MOVE "acceptance US15 44-8§9 9 Wither effect on difficulty 2 lasts 200 ticks" TO WS-CASE
     MOVE 200 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N2
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 3 TO WS-N1
     CALL "Q8-SKULL-WITHER" USING WS-N1 WS-N2 WS-N3
     MOVE "acceptance US15 44-8§9 9 Wither effect on difficulty 3 lasts 800 ticks" TO WS-CASE
     MOVE 800 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N2
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-8§9 9 Wither amplifier 1 (Wither II)" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N3
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 1 TO WS-N4
     CALL "Q8-FIREBALL-FIRE" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-8§9 9 large fireball with mob_griefing: fire and block destruction" TO WS-CASE
     MOVE 11 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N2 * 10 + WS-N3
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 1 TO WS-N4
     CALL "Q8-FIREBALL-FIRE" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-8§9 9 without mob_griefing neither" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N2 * 10 + WS-N3
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 3 TO WS-N4
     CALL "Q8-FIREBALL-FIRE" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-8§9 9 the radius is the explosionPower" TO WS-CASE
     MOVE 3 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N5
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 0 TO WS-N4
     CALL "Q8-FIREBALL-FIRE" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-8§9 9 the default explosionPower is 1" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N5
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     STOP RUN.
 END PROGRAM TEST-Q44-44-8-9-RULES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CHK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 LINKAGE SECTION.
 01 L-CASE                 PIC X(160).
 01 L-EXPECTED             BINARY-LONG.
 01 L-OBSERVED             BINARY-LONG.
 PROCEDURE DIVISION USING L-CASE L-EXPECTED L-OBSERVED.
     MOVE "N" TO TL-MODE
     MOVE L-CASE TO TL-CASE
     MOVE L-EXPECTED TO TL-EXPECTED-N
     MOVE L-OBSERVED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.
 END PROGRAM TEST-CHK.
