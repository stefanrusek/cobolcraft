*> Acceptance test of docs/protocol/44-residual-mob-questions-8-vehicles-and-projectiles.md section 8 as rule functions (lane 002-lane-p49j-b, T24200 range): wind charge parameters, bounding box, collision filter, the high-altitude explosion, the burst centre (12.7), the flying player knockback, immune block resistance and the entity hit result.

*> The functions of core/src/q44-44-8.cob are not called by a tick (no entity engine for them yet, see the lane task list).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-8-8.
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
     MOVE 0 TO WS-N1
     CALL "Q8-WIND-PARAMS" USING WS-N1 WS-A WS-B
     MOVE "acceptance US15 44-8§8 8 the player's wind charge: radius 1.2" TO WS-CASE
     MOVE 1200 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-A * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-8§8 8 the player's charge: knockback multiplier 1.22" TO WS-CASE
     MOVE 1220 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-B * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     CALL "Q8-WIND-PARAMS" USING WS-N1 WS-A WS-B
     MOVE "acceptance US15 44-8§8 8 the breeze charge: radius 3.0" TO WS-CASE
     MOVE 3000 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-A * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-8§8 8 the breeze charge has no multiplier" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-B * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 65 TO WS-A
     CALL "Q8-WIND-BOX" USING WS-A WS-B WS-C WS-D
     MOVE "acceptance US15 44-8§8 8 the box bottom is 0.15 below the position (y 65: 64.85)" TO WS-CASE
     MOVE 64850 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-B * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-8§8 8 the box top is 0.3125 above the bottom" TO WS-CASE
     MOVE 65162 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-C * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-8§8 8 the half width is 0.15625" TO WS-CASE
     MOVE 156 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-D * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 1 TO WS-N3
     MOVE 1 TO WS-N4
     CALL "Q8-WIND-CAN-HIT" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-8§8 8 a wind charge never hits another wind charge" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N5
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 1 TO WS-N3
     MOVE 1 TO WS-N4
     CALL "Q8-WIND-CAN-HIT" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-8§8 8 never an end crystal" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N5
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 1 TO WS-N3
     MOVE 1 TO WS-N4
     CALL "Q8-WIND-CAN-HIT" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-8§8 8 a pickable entity with physics is hit" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N5
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 1 TO WS-N3
     MOVE 0 TO WS-N4
     CALL "Q8-WIND-CAN-HIT" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-8§8 8 an entity without physics is not" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N5
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 0 TO WS-N3
     MOVE 1 TO WS-N4
     CALL "Q8-WIND-CAN-HIT" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-8§8 8 an unpickable entity is not" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N5
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 351 TO WS-N1
     MOVE 320 TO WS-N2
     CALL "Q8-WIND-TICK" USING WS-N1 WS-N2 WS-N3
     MOVE "acceptance US15 44-8§8 8 a charge at block y 350 over maxY 320 explodes" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N3
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 350 TO WS-N1
     MOVE 320 TO WS-N2
     CALL "Q8-WIND-TICK" USING WS-N1 WS-N2 WS-N3
     MOVE "acceptance US15 44-8§8 8 at exactly maxY + 30 it does not" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N3
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 15.3 TO WS-A
     MOVE 64 TO WS-B
     MOVE 3.2 TO WS-C
     MOVE 0 TO WS-N1 WS-N3
     MOVE 1 TO WS-N2
     CALL "Q8-WIND-CENTRE" USING WS-A WS-B WS-C WS-N1 WS-N2 WS-N3 WS-D WS-E WS-F
     MOVE "acceptance US15 44-8§8 8 12.7 the burst centre of a hit on the top face of (15.3, 64, 3.2): y 64.25" TO WS-CASE
     MOVE 64250 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-E * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-8§8 8 12.7 the centre x is unchanged" TO WS-CASE
     MOVE 15300 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-D * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 10 TO WS-A WS-B WS-C
     MOVE 1 TO WS-N1
     MOVE 0 TO WS-N2 WS-N3
     CALL "Q8-WIND-CENTRE" USING WS-A WS-B WS-C WS-N1 WS-N2 WS-N3 WS-D WS-E WS-F
     MOVE "acceptance US15 44-8§8 8 a hit on an east face moves the centre 0.25 along x" TO WS-CASE
     MOVE 10250 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-D * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 1.22 TO WS-A
     CALL "Q8-WIND-KB-MULT" USING WS-N1 WS-A WS-B
     MOVE "acceptance US15 44-8§8 8 a flying player is not pushed" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-B * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     CALL "Q8-WIND-KB-MULT" USING WS-N1 WS-A WS-B
     MOVE "acceptance US15 44-8§8 8 a walking player gets the multiplier" TO WS-CASE
     MOVE 1220 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-B * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 1 TO WS-N2
     CALL "Q8-WIND-RESIST" USING WS-N1 WS-N2 WS-A
     MOVE "acceptance US15 44-8§8 8 a member of the immune set resists 3600000.0" TO WS-CASE
     MOVE 3600000 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-A
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 0 TO WS-N2
     CALL "Q8-WIND-RESIST" USING WS-N1 WS-N2 WS-A
     MOVE "acceptance US15 44-8§8 8 another block has an empty result (-1)" TO WS-CASE
     MOVE -1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-A
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 1 TO WS-N2
     CALL "Q8-WIND-RESIST" USING WS-N1 WS-N2 WS-A
     MOVE "acceptance US15 44-8§8 8 without an immune set the base calculator is used (-1 here)" TO WS-CASE
     MOVE -1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-A
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 1 TO WS-N3
     CALL "Q8-WIND-HIT" USING WS-N1 WS-N2 WS-N3 WS-A WS-N4 WS-N5
     MOVE "acceptance US15 44-8§8 8 entity hit: damage 1.0" TO WS-CASE
     MOVE 1000 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-A * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-8§8 8 entity hit: post-attack effects on a living target that was hurt" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-8§8 8 entity hit: the explosion happens in every case" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N5
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 1 TO WS-N3
     CALL "Q8-WIND-HIT" USING WS-N1 WS-N2 WS-N3 WS-A WS-N4 WS-N5
     MOVE "acceptance US15 44-8§8 8 entity hit that did not hurt: no post-attack effects but still an explosion" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4 * 10 + WS-N5
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     STOP RUN.
 END PROGRAM TEST-Q44-44-8-8.

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
