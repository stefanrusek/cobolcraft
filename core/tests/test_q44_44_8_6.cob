*> Acceptance test of docs/protocol/44-residual-mob-questions-8-vehicles-and-projectiles.md sections 6 and 8 (no-deflect window) as rule functions (lane 002-lane-p49j-b, T24200 range): the projectile framework: computeMargin, checkLeftOwner, canHitEntity, the four deflections with the worked values, hit-or-deflect, border hits, onDeflection, the wind charge no-deflect window and bubble columns on projectiles.

*> The functions of core/src/q44-44-8.cob are not called by a tick (no entity engine for them yet, see the lane task list).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-8-6.
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
     MOVE 2 TO WS-N1
     CALL "Q8-MARGIN" USING WS-N1 WS-A
     MOVE "acceptance US15 44-8§6 6.2 margin at tick 2 is 0" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-A * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     CALL "Q8-MARGIN" USING WS-N1 WS-A
     MOVE "acceptance US15 44-8§6 6.2 margin at tick 0 is 0 (not negative)" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-A * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 3 TO WS-N1
     CALL "Q8-MARGIN" USING WS-N1 WS-A
     MOVE "acceptance US15 44-8§6 6.2 margin at tick 3 is 0.05" TO WS-CASE
     MOVE 50 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-A * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 8 TO WS-N1
     CALL "Q8-MARGIN" USING WS-N1 WS-A
     MOVE "acceptance US15 44-8§6 6.2 margin at tick 8 is 0.3" TO WS-CASE
     MOVE 300 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-A * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 40 TO WS-N1
     CALL "Q8-MARGIN" USING WS-N1 WS-A
     MOVE "acceptance US15 44-8§6 6.2 margin at tick 40 stays 0.3" TO WS-CASE
     MOVE 300 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-A * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 0 TO WS-N3
     MOVE 0 TO WS-N4
     CALL "Q8-LEFT-OWNER" USING WS-N1 WS-N2 WS-N3 WS-N4
     MOVE "acceptance US15 44-8§6 6.1 a fresh projectile inside its owner's box has not left (checked)" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N1
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-8§6 6.1 and it is marked checked" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N2
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 0 TO WS-N3
     MOVE 1 TO WS-N4
     CALL "Q8-LEFT-OWNER" USING WS-N1 WS-N2 WS-N3 WS-N4
     MOVE "acceptance US15 44-8§6 6.1 a projectile clear of the owner's boxes has left" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N1
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 1 TO WS-N3
     MOVE 0 TO WS-N4
     CALL "Q8-LEFT-OWNER" USING WS-N1 WS-N2 WS-N3 WS-N4
     MOVE "acceptance US15 44-8§6 6.1 a projectile without an owner has left" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N1
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 0 TO WS-N3
     MOVE 0 TO WS-N4
     CALL "Q8-LEFT-OWNER" USING WS-N1 WS-N2 WS-N3 WS-N4
     MOVE "acceptance US15 44-8§6 6.1 once left it stays left (nothing recomputed)" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N1
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 0 TO WS-N3
     MOVE 1 TO WS-N4
     CALL "Q8-LEFT-OWNER" USING WS-N1 WS-N2 WS-N3 WS-N4
     MOVE "acceptance US15 44-8§6 6.1 a projectile already checked this tick is not rechecked" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N1
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 1 TO WS-N3
     MOVE 0 TO WS-N4
     CALL "Q8-CAN-HIT" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-8§6 6.1 canHitEntity: an ordinary target is hit" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N5
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 1 TO WS-N3
     MOVE 0 TO WS-N4
     CALL "Q8-CAN-HIT" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-8§6 6.1 an entity that cannot be hit is not" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N5
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 0 TO WS-N3
     MOVE 1 TO WS-N4
     CALL "Q8-CAN-HIT" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-8§6 6.1 a passenger of the owner's vehicle before the owner was left is not hit" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N5
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 1 TO WS-N3
     MOVE 1 TO WS-N4
     CALL "Q8-CAN-HIT" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-8§6 6.1 after leaving the owner the companion is hit" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N5
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 0 TO WS-N3
     MOVE 1 TO WS-N4
     CALL "Q8-CAN-HIT" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-8§6 6.1 without an owner the companion is hit" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N5
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0.4 TO WS-A
     MOVE 0.2 TO WS-B
     MOVE -0.6 TO WS-C
     MOVE 1 TO WS-D
     MOVE 1 TO WS-E
     MOVE 1 TO WS-F
     MOVE 10 TO WS-G
     MOVE 0 TO WS-H
     CALL "Q8-REVERSE" USING WS-A WS-B WS-C WS-D WS-E WS-F WS-G WS-H
     MOVE "acceptance US15 44-8§6 6.3 REVERSE s = 1: vx 0.4 becomes -0.2 (thousandths)" TO WS-CASE
     MOVE -200 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-A * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-8§6 6.3 REVERSE s = 1: vy 0.2 becomes -0.1" TO WS-CASE
     MOVE -100 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-B * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-8§6 6.3 REVERSE s = 1: vz -0.6 becomes 0.3" TO WS-CASE
     MOVE 300 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-C * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-8§6 6.3 REVERSE yaw at draw 0: +170" TO WS-CASE
     MOVE 180 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-G
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     MOVE 1 TO WS-C
     MOVE 1 TO WS-D
     MOVE 1 TO WS-E
     MOVE 1 TO WS-F
     MOVE 0 TO WS-G
     MOVE 1 TO WS-H
     CALL "Q8-REVERSE" USING WS-A WS-B WS-C WS-D WS-E WS-F WS-G WS-H
     MOVE "acceptance US15 44-8§6 6.3 REVERSE yaw at draw 1: +190" TO WS-CASE
     MOVE 190 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-G
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 3 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     MOVE 0.2 TO WS-D
     MOVE 0.2 TO WS-E
     MOVE 0.2 TO WS-F
     MOVE 0 TO WS-G
     MOVE 0.5 TO WS-H
     CALL "Q8-REVERSE" USING WS-A WS-B WS-C WS-D WS-E WS-F WS-G WS-H
     MOVE "acceptance US15 44-8§6 6.3 12.5 the shield bounce s = 0.2: 3.0 becomes -0.3" TO WS-CASE
     MOVE -300 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-A * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     MOVE 1 TO WS-C
     MOVE 0.02 TO WS-D
     MOVE 0.2 TO WS-E
     MOVE 0.02 TO WS-F
     MOVE 0 TO WS-G
     MOVE 0 TO WS-H
     CALL "Q8-REVERSE" USING WS-A WS-B WS-C WS-D WS-E WS-F WS-G WS-H
     MOVE "acceptance US15 44-8§6 6.3 trident s = (0.02, 0.2, 0.02): vx 1 becomes -0.01" TO WS-CASE
     MOVE -10 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-A * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-8§6 6.3 trident vertical x 0.1 (vy 1 becomes -0.1)" TO WS-CASE
     MOVE -100 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-B * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-A WS-B
     MOVE 1 TO WS-C WS-D WS-E WS-F
     CALL "Q8-AIM-DEFLECT" USING WS-A WS-B WS-C WS-D WS-E WS-F WS-G WS-H WS-J
     MOVE "acceptance US15 44-8§6 6.3 AIM_DEFLECT: look (0, 0, 1) at s = 1" TO WS-CASE
     MOVE 1000 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-J * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0.6 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0.8 TO WS-C
     MOVE 2 TO WS-D WS-E WS-F
     CALL "Q8-AIM-DEFLECT" USING WS-A WS-B WS-C WS-D WS-E WS-F WS-G WS-H WS-J
     MOVE "acceptance US15 44-8§6 6.3 AIM_DEFLECT at s = 2: the look vector scaled" TO WS-CASE
     MOVE 1200 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-G * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 3 TO WS-A
     MOVE 0 TO WS-B
     MOVE 4 TO WS-C
     MOVE 2 TO WS-D
     CALL "Q8-MOMENTUM-DEFLECT" USING WS-A WS-B WS-C WS-D WS-E WS-F WS-G
     MOVE "acceptance US15 44-8§6 6.3 MOMENTUM_DEFLECT: the normalised known speed (3, 0, 4) x s 2" TO WS-CASE
     MOVE 1200 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-E * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-8§6 6.3 MOMENTUM_DEFLECT z component" TO WS-CASE
     MOVE 1600 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-G * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 0 TO WS-N2
     CALL "Q8-HIT-DEFLECT" USING WS-N1 WS-N2 WS-N3 WS-N4
     MOVE "acceptance US15 44-8§6 6.3 no deflection: the hit is processed" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-8§6 6.3 no deflection: nothing deflected" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N3
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 0 TO WS-N2
     CALL "Q8-HIT-DEFLECT" USING WS-N1 WS-N2 WS-N3 WS-N4
     MOVE "acceptance US15 44-8§6 6.3 a deflecting entity: the hit is not processed" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-8§6 6.3 and the projectile deflects" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N3
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 1 TO WS-N2
     CALL "Q8-HIT-DEFLECT" USING WS-N1 WS-N2 WS-N3 WS-N4
     MOVE "acceptance US15 44-8§6 6.3 the entity that last deflected it does not deflect it again" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N3
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 0 TO WS-N3
     CALL "Q8-BORDER-HIT" USING WS-N1 WS-N2 WS-N3 WS-A
     MOVE "acceptance US15 44-8§6 6.3 an arrow at the world border: REVERSE s 0.2" TO WS-CASE
     MOVE 200 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-A * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 0 TO WS-N3
     CALL "Q8-BORDER-HIT" USING WS-N1 WS-N2 WS-N3 WS-A
     MOVE "acceptance US15 44-8§6 6.3 another projectile at the border: no bounce" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-A * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 1 TO WS-N3
     CALL "Q8-BORDER-HIT" USING WS-N1 WS-N2 WS-N3 WS-A
     MOVE "acceptance US15 44-8§6 6.3 a block hit on air is no hit" TO WS-CASE
     MOVE -1000 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-A * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 0 TO WS-N3
     CALL "Q8-BORDER-HIT" USING WS-N1 WS-N2 WS-N3 WS-A
     MOVE "acceptance US15 44-8§6 6.3 an ordinary block hit runs onHit" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-A * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0.4 TO WS-A
     MOVE 1 TO WS-N1
     CALL "Q8-ON-DEFLECTION" USING WS-A WS-N1 WS-B
     MOVE "acceptance US15 44-8§6 6.4 onDeflection by an attack: acceleration power 0.1" TO WS-CASE
     MOVE 100 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-B * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0.4 TO WS-A
     MOVE 0 TO WS-N1
     CALL "Q8-ON-DEFLECTION" USING WS-A WS-N1 WS-B
     MOVE "acceptance US15 44-8§6 6.4 onDeflection otherwise halves it" TO WS-CASE
     MOVE 200 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-B * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 5 TO WS-N1
     CALL "Q8-NO-DEFLECT" USING WS-N1 WS-N2
     MOVE "acceptance US15 44-8§6 8 a fresh wind charge (5 ticks) refuses deflection" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N2
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-8§6 8 the counter decrements" TO WS-CASE
     MOVE 4 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N1
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     CALL "Q8-NO-DEFLECT" USING WS-N1 WS-N2
     MOVE "acceptance US15 44-8§6 8 at 0 it allows deflection" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N2
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-A
     MOVE 0 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 0 TO WS-N3
     CALL "Q8-PROJ-BUBBLE" USING WS-N1 WS-N2 WS-N3 WS-A
     MOVE "acceptance US15 44-8§6 6.6 above a push column: vy + 0.1" TO WS-CASE
     MOVE 100 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-A * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-A
     MOVE 1 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 0 TO WS-N3
     CALL "Q8-PROJ-BUBBLE" USING WS-N1 WS-N2 WS-N3 WS-A
     MOVE "acceptance US15 44-8§6 6.6 above a drag column: vy - 0.03" TO WS-CASE
     MOVE -30 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-A * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-A
     MOVE 0 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 0 TO WS-N3
     CALL "Q8-PROJ-BUBBLE" USING WS-N1 WS-N2 WS-N3 WS-A
     MOVE "acceptance US15 44-8§6 6.6 inside a push column: vy + 0.06" TO WS-CASE
     MOVE 60 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-A * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-A
     MOVE 1 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 0 TO WS-N3
     CALL "Q8-PROJ-BUBBLE" USING WS-N1 WS-N2 WS-N3 WS-A
     MOVE "acceptance US15 44-8§6 6.6 inside a drag column: vy - 0.03" TO WS-CASE
     MOVE -30 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-A * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-A
     MOVE 0 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 1 TO WS-N3
     CALL "Q8-PROJ-BUBBLE" USING WS-N1 WS-N2 WS-N3 WS-A
     MOVE "acceptance US15 44-8§6 6.6 an arrow in the ground does nothing" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-A * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     STOP RUN.
 END PROGRAM TEST-Q44-44-8-6.

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
