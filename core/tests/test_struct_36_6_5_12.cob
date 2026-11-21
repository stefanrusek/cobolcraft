*> Acceptance test of the terrain and water of the ocean monument (docs/protocol/36-structures-6-ocean.md section 5.12 with 5.7 steps 1, 4 and 5; core/src/struct-mon-build.cob): the monument of world seed 0, start chunk (0, 0),
*> direction south is drawn over the 25 windows around the start on a world of scattered stone, ice, packed ice and blue ice (core/tests/MONTEST.cpy) and read back against that world: every cell of the stepped ring
*> of five layers around the box (the four boxes of step 5 for i 0 to 4, from y 2 i to 23 local) is water below the sea level, except the ice, packed ice, blue ice and water that were there, which are never removed;
*> the 23 foundation pillars of 4 x 4 blocks (all seven rows for the outer columns, the two end rows for columns 1, 2, 4 and 5, and only the far end for column 3) reach down from local y -1 through air to the first solid
*> block (a column over a solid block stays as it was) and carry bricks at local y 0; no cell below the box outside the pillars changes.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-6-5-12.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY STRUCTMON.
 COPY STRUCTPIECE.
 COPY MTDATA.
 COPY CELLS.
 01 WS-IX                  BINARY-LONG.
 01 WS-IZ                  BINARY-LONG.
 01 WS-WX                  BINARY-LONG.
 01 WS-WZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LY                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-IDX                 BINARY-LONG.
 01 WS-SEED                BINARY-LONG VALUE 1300.
 01 WS-X0                  BINARY-LONG VALUE -29.
 01 WS-Z0                  BINARY-LONG VALUE -29.
 01 WS-X1                  BINARY-LONG VALUE 28.
 01 WS-Z1                  BINARY-LONG VALUE 28.
 01 WS-Y0                  BINARY-LONG VALUE 39.
 01 WS-Y1                  BINARY-LONG VALUE 61.
 01 WS-ORIENT              BINARY-LONG VALUE 0.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 01 WS-TYPE                BINARY-LONG VALUE 38.
 01 WS-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==B-==.
 01 WS-PRE-TAB.
    05 WS-PRE              BINARY-LONG OCCURS 10496 TIMES.
 01 WS-STATE               BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-CODE                BINARY-LONG.
 01 WS-RING                BINARY-LONG.
 01 WS-RING-BAD            BINARY-LONG VALUE 0.
 01 WS-RING-N              BINARY-LONG VALUE 0.
 01 WS-KEPT-N              BINARY-LONG VALUE 0.
 01 WS-FOUND-BAD           BINARY-LONG VALUE 0.
 01 WS-FOUND-N             BINARY-LONG VALUE 0.
 01 WS-TOP-N               BINARY-LONG VALUE 0.
 01 WS-OTHER-BAD           BINARY-LONG VALUE 0.
 01 WS-GX                  BINARY-LONG.
 01 WS-GZ                  BINARY-LONG.
 01 WS-IN                  BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-RUN                 BINARY-LONG.
 01 WS-YY                  BINARY-LONG.
 01 WS-PRE-CODE            BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE "content/tests/fixtures/std" TO CS-GENERATED-DIR
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "MT-SETUP"
     CALL "SPB-BOX-NEW" USING WS-X0 WS-Y0 WS-Z0 WS-X1 WS-Y1 WS-Z1 WS-BOX
     CALL "SPB-RESET"
     CALL "SPB-ADD" USING WS-TYPE WS-ORIENT WS-ZERO WS-ZERO2 WS-BOX WS-ROW
     MOVE 0 TO SP-SEED
     PERFORM VARYING WS-IX FROM -2 BY 1 UNTIL WS-IX > 1
         PERFORM VARYING WS-IZ FROM -2 BY 1 UNTIL WS-IZ > 1
             MOVE WS-IX TO WS-WX
             MOVE WS-IZ TO WS-WZ
             CALL "MT-WINDOW" USING WS-WX WS-WZ
             PERFORM SNAP-PRE
             CALL "MT-SEED" USING WS-SEED
             CALL "MON-POST" USING WS-ROW
             PERFORM CHECK-WINDOW
         END-PERFORM
     END-PERFORM
     MOVE "acceptance US12 36-6§5.12 Terrain and water: the stepped ring holds cells in the windows (the check is not empty)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-RING-N > 5000
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-6§5.12 Terrain and water: every cell of the stepped ring is water, except that ice, packed ice, blue ice and water stay" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-RING-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-6§5.12 Terrain and water: ice of the ring was there and is still there (the clearing never removes it)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-KEPT-N > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-6§5.12 Terrain and water: the 23 foundation pillars carry 23 x 16 = 368 bricks at local y 0" TO TL-CASE
     MOVE 368 TO TL-EXPECTED-N
     MOVE WS-TOP-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-6§5.12 Terrain and water: the columns below the pillars hold bricks through air down to the first solid block and nothing else changes at y 31 to 38" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-FOUND-BAD + WS-OTHER-BAD
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-6§5.12 Terrain and water: the pillars did reach down (bricks below y 38 exist)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-FOUND-N > 100
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.

*> the states of the window's layers y 30 to 70 before the monument, by (y - 30) * 256 + z * 16 + x + 1
 SNAP-PRE.
     SET ADDRESS OF CE-CHUNK TO MT-PTR
     PERFORM VARYING WS-Y FROM 30 BY 1 UNTIL WS-Y > 70
         PERFORM VARYING WS-Z FROM 0 BY 1 UNTIL WS-Z > 15
             PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 15
                 COMPUTE WS-IDX = (WS-Y + 64) * 256 + WS-Z * 16 + WS-X + 1
                 COMPUTE WS-J = (WS-Y - 30) * 256 + WS-Z * 16 + WS-X + 1
                 MOVE CE-STATE(WS-IDX) TO WS-PRE(WS-J)
             END-PERFORM
         END-PERFORM
     END-PERFORM.

*> every cell of y 31 to 62 of the window against the rules of the ring and the pillars
 CHECK-WINDOW.
     SET ADDRESS OF CE-CHUNK TO MT-PTR
     PERFORM VARYING WS-Y FROM 31 BY 1 UNTIL WS-Y > 62
         PERFORM VARYING WS-Z FROM 0 BY 1 UNTIL WS-Z > 15
             PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 15
                 COMPUTE WS-IDX = (WS-Y + 64) * 256 + WS-Z * 16 + WS-X + 1
                 COMPUTE WS-J = (WS-Y - 30) * 256 + WS-Z * 16 + WS-X + 1
                 MOVE CE-STATE(WS-IDX) TO WS-STATE
                 COMPUTE WS-LX = WS-WX * 16 + WS-X + 29
                 COMPUTE WS-LZ = WS-WZ * 16 + WS-Z + 29
                 COMPUTE WS-LY = WS-Y - 39
                 PERFORM RING-OF
                 IF WS-RING = 1
                     ADD 1 TO WS-RING-N
                     MOVE WS-PRE(WS-J) TO WS-WANT
                     MOVE WS-PRE(WS-J) TO WS-CODE
                     PERFORM PRE-CODE-OF
                     IF WS-PRE-CODE NOT = 7 AND WS-PRE-CODE NOT = 9 AND WS-PRE-CODE NOT = 10 AND WS-PRE-CODE NOT = 11
                         MOVE MT-ST(8) TO WS-WANT
                     ELSE
                         IF WS-PRE-CODE NOT = 7
                             ADD 1 TO WS-KEPT-N
                         END-IF
                     END-IF
                     IF WS-STATE NOT = WS-WANT
                         ADD 1 TO WS-RING-BAD
                     END-IF
                 END-IF
                 IF WS-LY <= -1
                     PERFORM PILLAR-OF
                     PERFORM CHECK-LOW
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
*>   the pillar tops at local y 0 (world y 39)
     MOVE 39 TO WS-Y
     PERFORM VARYING WS-Z FROM 0 BY 1 UNTIL WS-Z > 15
         PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 15
             COMPUTE WS-IDX = (WS-Y + 64) * 256 + WS-Z * 16 + WS-X + 1
             COMPUTE WS-LX = WS-WX * 16 + WS-X + 29
             COMPUTE WS-LZ = WS-WZ * 16 + WS-Z + 29
             MOVE 0 TO WS-LY
             PERFORM PILLAR-OF
             IF WS-IN = 1 AND CE-STATE(WS-IDX) = MT-ST(2)
                 ADD 1 TO WS-TOP-N
             END-IF
         END-PERFORM
     END-PERFORM.

*> WS-PRE-CODE: the code of the state WS-CODE
 PRE-CODE-OF.
     MOVE 99 TO WS-PRE-CODE
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 12
         IF WS-CODE = MT-ST(WS-K)
             COMPUTE WS-PRE-CODE = WS-K - 1
         END-IF
     END-PERFORM.

*> WS-RING 1 when the local cell (WS-LX, WS-LY, WS-LZ) is in a box of 5.7 step 5 for some i
 RING-OF.
     MOVE 0 TO WS-RING
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 4
         IF WS-LY >= 2 * WS-I AND WS-LY <= 23
             IF (WS-LX = -1 - WS-I OR WS-LX = 58 + WS-I) AND WS-LZ >= -1 - WS-I AND WS-LZ <= 58 + WS-I
                 MOVE 1 TO WS-RING
             END-IF
             IF (WS-LZ = -1 - WS-I OR WS-LZ = 58 + WS-I) AND WS-LX >= 0 - WS-I AND WS-LX <= 57 + WS-I
                 MOVE 1 TO WS-RING
             END-IF
         END-IF
     END-PERFORM.

*> WS-IN 1 when the local column (WS-LX, WS-LZ) is in one of the 23 pillars of 5.7 step 4 (4 x 4 blocks with the minimum corner at (9 gx, 9 gz): all gz for gx 0 and 6, gz 0 and 6 for gx 1, 2, 4, 5, gz 6 for gx 3)
 PILLAR-OF.
     MOVE 0 TO WS-IN
     IF WS-LX >= 0 AND WS-LX <= 57 AND WS-LZ >= 0 AND WS-LZ <= 57
         COMPUTE WS-GX = WS-LX / 9
         COMPUTE WS-GZ = WS-LZ / 9
         COMPUTE WS-A = WS-LX - WS-GX * 9
         COMPUTE WS-B = WS-LZ - WS-GZ * 9
         IF WS-A <= 3 AND WS-B <= 3 AND WS-GX <= 6 AND WS-GZ <= 6
             EVALUATE TRUE
                 WHEN WS-GX = 0 OR WS-GX = 6
                     MOVE 1 TO WS-IN
                 WHEN WS-GX = 3
                     IF WS-GZ = 6
                         MOVE 1 TO WS-IN
                     END-IF
                 WHEN OTHER
                     IF WS-GZ = 0 OR WS-GZ = 6
                         MOVE 1 TO WS-IN
                     END-IF
             END-EVALUATE
         END-IF
     END-IF.

*> a cell below the box (local y < 0, world y 31 to 38): in a pillar column it is a brick while every cell from 38 down to it was air before, else as it was; outside the pillars as it was
 CHECK-LOW.
     MOVE WS-PRE(WS-J) TO WS-WANT
     IF WS-IN = 1
         MOVE 1 TO WS-RUN
         PERFORM VARYING WS-YY FROM 38 BY -1 UNTIL WS-YY < WS-Y
             COMPUTE WS-K = (WS-YY - 30) * 256 + WS-Z * 16 + WS-X + 1
             IF WS-PRE(WS-K) NOT = MT-ST(1)
                 MOVE 0 TO WS-RUN
             END-IF
         END-PERFORM
         IF WS-RUN = 1
             MOVE MT-ST(2) TO WS-WANT
             ADD 1 TO WS-FOUND-N
         END-IF
         IF WS-STATE NOT = WS-WANT
             ADD 1 TO WS-FOUND-BAD
         END-IF
     ELSE
         IF WS-STATE NOT = WS-WANT
             ADD 1 TO WS-OTHER-BAD
         END-IF
     END-IF.

 END PROGRAM TEST-STRUCT-36-6-5-12.
 COPY MONTEST.
 COPY NOSPAWN.
 COPY CORETEST.
