*> Acceptance test of docs/protocol/44-residual-mob-questions-8-vehicles-and-projectiles.md section 10 as rule functions (lane 002-lane-p49j-b, T24200 range): the ender pearl vanish and teleport rules, the lingering cloud parameters (V16), the trident return decision and pull, the trident single hit, the experience bottle award and the fishing hook stop and pull rules (V21).

*> The functions of core/src/q44-44-8.cob are not called by a tick (no entity engine for them yet, see the lane task list).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-8-10.
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
     MOVE 0 TO WS-N2
     MOVE 1 TO WS-N3
     CALL "Q8-PEARL-VANISH" USING WS-N1 WS-N2 WS-N3 WS-N4
     MOVE "acceptance US15 44-8§10 10 the pearl of a dead player vanishes with the rule on" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 0 TO WS-N3
     CALL "Q8-PEARL-VANISH" USING WS-N1 WS-N2 WS-N3 WS-N4
     MOVE "acceptance US15 44-8§10 10 not with the rule off" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 1 TO WS-N3
     CALL "Q8-PEARL-VANISH" USING WS-N1 WS-N2 WS-N3 WS-N4
     MOVE "acceptance US15 44-8§10 10 not when the owner won the game" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 1 TO WS-N3
     CALL "Q8-PEARL-VANISH" USING WS-N1 WS-N2 WS-N3 WS-N4
     MOVE "acceptance US15 44-8§10 10 not when the owner is alive" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 0 TO WS-N3
     CALL "Q8-PEARL-CAN-TELEPORT" USING WS-N1 WS-N2 WS-N3 WS-N4
     MOVE "acceptance US15 44-8§10 10 a pearl cannot take the owner from the End to the Overworld before the credits" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 1 TO WS-N3
     CALL "Q8-PEARL-CAN-TELEPORT" USING WS-N1 WS-N2 WS-N3 WS-N4
     MOVE "acceptance US15 44-8§10 10 after the credits it can" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 0 TO WS-N3
     CALL "Q8-PEARL-CAN-TELEPORT" USING WS-N1 WS-N2 WS-N3 WS-N4
     MOVE "acceptance US15 44-8§10 10 within the Overworld it can" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "Q8-LINGER" USING WS-A WS-B WS-N1 WS-N2 WS-C
     MOVE "acceptance US15 44-8§10 10 V16 lingering cloud: radius 3.0" TO WS-CASE
     MOVE 3000 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-A * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-8§10 10 V16 radiusOnUse -0.5" TO WS-CASE
     MOVE -500 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-B * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-8§10 10 V16 duration 600" TO WS-CASE
     MOVE 600 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N1
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-8§10 10 V16 wait time 10" TO WS-CASE
     MOVE 10 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N2
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-8§10 10 V16 radius per tick -0.005 (millionths)" TO WS-CASE
     MOVE -5000 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-C * 1000000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 3 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 0 TO WS-N3
     MOVE 1 TO WS-N4
     MOVE 1 TO WS-N5
     MOVE 1 TO WS-N6
     MOVE 5 TO WS-A
     MOVE 0.6 TO WS-B
     CALL "Q8-TRIDENT-RETURN" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5 WS-N6 WS-A WS-B WS-N7
     MOVE "acceptance US15 44-8§10 10 a loyal trident that dealt damage returns to a player" TO WS-CASE
     MOVE 3 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N7
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 0 TO WS-N3
     MOVE 1 TO WS-N4
     MOVE 1 TO WS-N5
     MOVE 1 TO WS-N6
     MOVE 5 TO WS-A
     MOVE 0.6 TO WS-B
     CALL "Q8-TRIDENT-RETURN" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5 WS-N6 WS-A WS-B WS-N7
     MOVE "acceptance US15 44-8§10 10 a trident without loyalty does not return" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N7
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 3 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 0 TO WS-N3
     MOVE 1 TO WS-N4
     MOVE 1 TO WS-N5
     MOVE 1 TO WS-N6
     MOVE 5 TO WS-A
     MOVE 0.6 TO WS-B
     CALL "Q8-TRIDENT-RETURN" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5 WS-N6 WS-A WS-B WS-N7
     MOVE "acceptance US15 44-8§10 10 a loyal trident that has not hit and has physics does not return" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N7
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 3 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 1 TO WS-N3
     MOVE 1 TO WS-N4
     MOVE 1 TO WS-N5
     MOVE 1 TO WS-N6
     MOVE 5 TO WS-A
     MOVE 0.6 TO WS-B
     CALL "Q8-TRIDENT-RETURN" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5 WS-N6 WS-A WS-B WS-N7
     MOVE "acceptance US15 44-8§10 10 a no-physics loyal trident returns" TO WS-CASE
     MOVE 3 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N7
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 3 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 0 TO WS-N3
     MOVE 0 TO WS-N4
     MOVE 1 TO WS-N5
     MOVE 1 TO WS-N6
     MOVE 5 TO WS-A
     MOVE 0.6 TO WS-B
     CALL "Q8-TRIDENT-RETURN" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5 WS-N6 WS-A WS-B WS-N7
     MOVE "acceptance US15 44-8§10 10 without an owner it stays" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N7
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 3 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 0 TO WS-N3
     MOVE 1 TO WS-N4
     MOVE 0 TO WS-N5
     MOVE 1 TO WS-N6
     MOVE 5 TO WS-A
     MOVE 0.6 TO WS-B
     CALL "Q8-TRIDENT-RETURN" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5 WS-N6 WS-A WS-B WS-N7
     MOVE "acceptance US15 44-8§10 10 an unacceptable owner: drop and discard" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N7
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 3 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 0 TO WS-N3
     MOVE 1 TO WS-N4
     MOVE 1 TO WS-N5
     MOVE 0 TO WS-N6
     MOVE 1.5 TO WS-A
     MOVE 0.6 TO WS-B
     CALL "Q8-TRIDENT-RETURN" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5 WS-N6 WS-A WS-B WS-N7
     MOVE "acceptance US15 44-8§10 10 a non-player owner within width + 1 of the eye: discard" TO WS-CASE
     MOVE 2 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N7
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 3 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 0 TO WS-N3
     MOVE 1 TO WS-N4
     MOVE 1 TO WS-N5
     MOVE 0 TO WS-N6
     MOVE 2 TO WS-A
     MOVE 0.6 TO WS-B
     CALL "Q8-TRIDENT-RETURN" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5 WS-N6 WS-A WS-B WS-N7
     MOVE "acceptance US15 44-8§10 10 a non-player owner farther away: it returns" TO WS-CASE
     MOVE 3 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N7
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-A
     MOVE 4 TO WS-B
     MOVE 3 TO WS-C
     MOVE 2 TO WS-N1
     MOVE 1 TO WS-D
     MOVE 0 TO WS-E
     MOVE 0 TO WS-F
     MOVE 10 TO WS-G
     CALL "Q8-TRIDENT-PULL" USING WS-B WS-A WS-C WS-N1 WS-D WS-E WS-F WS-G
     MOVE "acceptance US15 44-8§10 10 pull: y + d.y x 0.015 x loyalty = 10.12 (thousandths)" TO WS-CASE
     MOVE 10120 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-G * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-8§10 10 pull: vx = 0.95 x 1 + 0 = 0.95" TO WS-CASE
     MOVE 950 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-D * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-8§10 10 pull: vy = 0 + 4/5 x 0.05 x 2 = 0.08" TO WS-CASE
     MOVE 80 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-E * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-8§10 10 pull: vz = 3/5 x 0.05 x 2 = 0.06" TO WS-CASE
     MOVE 60 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-F * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     CALL "Q8-TRIDENT-DAMAGE" USING WS-N1 WS-N2
     MOVE "acceptance US15 44-8§10 10 a trident hits once: findHitEntity finds nothing after dealtDamage" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N2
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     CALL "Q8-TRIDENT-DAMAGE" USING WS-N1 WS-N2
     MOVE "acceptance US15 44-8§10 10 before that it finds targets" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N2
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1 WS-N2
     CALL "Q8-XP-BOTTLE" USING WS-N1 WS-N2 WS-N3
     MOVE "acceptance US15 44-8§10 10.4 experience bottle: 3 + 0 + 0" TO WS-CASE
     MOVE 3 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N3
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 4 TO WS-N1 WS-N2
     CALL "Q8-XP-BOTTLE" USING WS-N1 WS-N2 WS-N3
     MOVE "acceptance US15 44-8§10 10.4 experience bottle: 3 + 4 + 4 = 11" TO WS-CASE
     MOVE 11 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N3
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 0 TO WS-N3
     MOVE 1024 TO WS-A
     CALL "Q8-HOOK-STOP" USING WS-N1 WS-N2 WS-N3 WS-A WS-N4
     MOVE "acceptance US15 44-8§10 10.1 V21 a hook within 32 blocks of an owner with a rod stays" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 0 TO WS-N3
     MOVE 1025 TO WS-A
     CALL "Q8-HOOK-STOP" USING WS-N1 WS-N2 WS-N3 WS-A WS-N4
     MOVE "acceptance US15 44-8§10 10.1 V21 a hook beyond 32 blocks is discarded" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 1 TO WS-N3
     MOVE 10 TO WS-A
     CALL "Q8-HOOK-STOP" USING WS-N1 WS-N2 WS-N3 WS-A WS-N4
     MOVE "acceptance US15 44-8§10 10.1 V21 an owner with a rod in the off hand keeps it" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 0 TO WS-N3
     MOVE 10 TO WS-A
     CALL "Q8-HOOK-STOP" USING WS-N1 WS-N2 WS-N3 WS-A WS-N4
     MOVE "acceptance US15 44-8§10 10.1 V21 an owner without a rod in either hand loses it" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 0 TO WS-N3
     MOVE 10 TO WS-A
     CALL "Q8-HOOK-STOP" USING WS-N1 WS-N2 WS-N3 WS-A WS-N4
     MOVE "acceptance US15 44-8§10 10.1 an owner that cannot interact loses it" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 10 TO WS-A
     MOVE 4 TO WS-B
     MOVE 0 TO WS-C
     CALL "Q8-HOOK-PULL" USING WS-A WS-B WS-C
     MOVE "acceptance US15 44-8§10 10.1 pull: velocity + (owner - hook) x 0.1 (x: 0 + (10 - 4) x 0.1 = 0.6)" TO WS-CASE
     MOVE 600 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-C * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     STOP RUN.
 END PROGRAM TEST-Q44-44-8-10.

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
