*> Implementation test (lane 002-lane-p49s, T38550 to T38555; docs/protocol/44-residual-mob-questions-8-vehicles-and-projectiles.md section 7.6): the touch range of a stuck arrow (the player's box
*> inflated by 1.0 horizontally and 0.5 vertically against the arrow's 0.5 x 0.5 box), the shakeTime of 7 ticks, the pickup mode by the owner (a player's arrow is taken, a mob's stays), the
*> arrow item added to the inventory, and a full inventory that leaves the arrow where it is.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-8-PICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CITEMS.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z0                  FLOAT-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-AX                  FLOAT-LONG.
 01 WS-AY                  FLOAT-LONG.
 01 WS-AZ                  FLOAT-LONG.
 01 WS-ZERO-F              FLOAT-LONG VALUE 0.
 01 WS-ZERO-G              FLOAT-LONG VALUE 0.
 01 WS-ZERO-H              FLOAT-LONG VALUE 0.
 01 WS-BASE                BINARY-LONG VALUE 2000.
 01 WS-OWNER               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ARROW-ITEM          BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-IN                  BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-MOB-OWNER           BINARY-LONG VALUE 999999.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE PL-X(WS-PLAYER) TO WS-X0
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z0
     COMPUTE WS-BX = FUNCTION INTEGER(WS-X0) - 20
     COMPUTE WS-BY = FUNCTION INTEGER(WS-Y) - 1
     COMPUTE WS-BZ = FUNCTION INTEGER(WS-Z0) - 20
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-BX WS-BZ 40 WS-BY 1
     MOVE "arrow" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-ARROW-ITEM
     MOVE "stone" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-STONE
     MOVE PL-ENTITY-ID(WS-PLAYER) TO WS-OWNER
*>   The reach test by position (the player stands at WS-X0, WS-Y; the arrow is a 0.5 box): horizontal limit 0.3 + 1.0 + 0.25 = 1.55, vertical from -1.0 up to 2.3.
     MOVE 1.5 TO WS-AX
     PERFORM TEST-REACH-X
     MOVE "acceptance US15 44-8§7.6 an arrow 1.5 blocks east is in reach" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-IN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1.6 TO WS-AX
     PERFORM TEST-REACH-X
     MOVE "acceptance US15 44-8§7.6 an arrow 1.6 blocks east is not" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-IN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2.2 TO WS-AY
     PERFORM TEST-REACH-Y
     MOVE "acceptance US15 44-8§7.6 an arrow 2.2 above the feet is in reach (the box reaches 0.5 over the head)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-IN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2.4 TO WS-AY
     PERFORM TEST-REACH-Y
     MOVE "acceptance US15 44-8§7.6 an arrow 2.4 above the feet is not" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-IN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -0.9 TO WS-AY
     PERFORM TEST-REACH-Y
     MOVE "acceptance US15 44-8§7.6 an arrow 0.9 below the feet is in reach (its top is 0.4 below)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-IN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -1.1 TO WS-AY
     PERFORM TEST-REACH-Y
     MOVE "acceptance US15 44-8§7.6 an arrow 1.1 below the feet is not" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-IN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A player's stuck arrow: not taken during the shakeTime (7 ticks), taken afterwards; the inventory gains one arrow item and the arrow is gone.
     MOVE 1.4 TO WS-AX
     MOVE 0 TO WS-AY
     MOVE 0 TO WS-AY
     PERFORM SPAWN-STUCK
     MOVE WS-OWNER TO EN-TARGET-ID(WS-ROW)
     PERFORM 6 TIMES
         CALL "ARROW-STEP" USING WS-ROW
     END-PERFORM
     MOVE "acceptance US15 44-8§7.6 the arrow is not taken while shakeTime runs (6 ticks)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-USED(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ARROW-STEP" USING WS-ROW
     MOVE "acceptance US15 44-8§7.6 the arrow is taken on the 7th tick" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-USED(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM COUNT-ARROWS
     MOVE "acceptance US15 44-8§7.6 the inventory holds one arrow" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Out of reach it stays.
     MOVE 3 TO WS-AX
     MOVE 0 TO WS-AY
     PERFORM SPAWN-STUCK
     MOVE WS-OWNER TO EN-TARGET-ID(WS-ROW)
     PERFORM 10 TIMES
         CALL "ARROW-STEP" USING WS-ROW
     END-PERFORM
     MOVE "acceptance US15 44-8§7.6 an arrow 3 blocks away stays" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-USED(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-ROW
*>   A mob's arrow keeps the mode DISALLOWED.
     MOVE 0.5 TO WS-AX
     MOVE 0 TO WS-AY
     PERFORM SPAWN-STUCK
     MOVE WS-MOB-OWNER TO EN-TARGET-ID(WS-ROW)
     PERFORM 10 TIMES
         CALL "ARROW-STEP" USING WS-ROW
     END-PERFORM
     MOVE "acceptance US15 44-8§7.6 a mob's arrow is never picked up (DISALLOWED)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-USED(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-ROW
*>   A stuck arrow is removed at age 1200.
     MOVE 0 TO WS-AY
     MOVE 3 TO WS-AX
     PERFORM SPAWN-STUCK
     MOVE 1199 TO EN-AGE(WS-ROW)
     CALL "ARROW-STEP" USING WS-ROW
     MOVE "acceptance US15 44-8§7.6 a stuck arrow disappears at age 1200" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-USED(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A flying arrow in free air: its pitch follows the velocity (gravity bends it down), Mth.atan2 of vy over the horizontal speed.
     MOVE 0.5 TO WS-ZERO-F
     COMPUTE WS-AX = WS-X0
     COMPUTE WS-AY = WS-Y + 3
     MOVE WS-Z0 TO WS-AZ
     CALL "ARROW-SPAWN" USING WS-DIM WS-AX WS-AY WS-AZ WS-ZERO-F WS-ZERO-G WS-ZERO-H WS-BASE WS-MOB-OWNER WS-ROW
     CALL "ARROW-STEP" USING WS-ROW
     MOVE "acceptance US15 44-8§7.6 a flying arrow pitches down after a tick of gravity" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-PITCH(WS-ROW) < 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-ROW
     MOVE 0 TO WS-ZERO-F
*>   A full inventory leaves the arrow.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
         MOVE WS-STONE TO PL-SLOT-ITEM(WS-PLAYER, WS-I)
         MOVE 64 TO PL-SLOT-COUNT(WS-PLAYER, WS-I)
     END-PERFORM
     MOVE 0.5 TO WS-AX
     MOVE 0 TO WS-AY
     PERFORM SPAWN-STUCK
     MOVE WS-OWNER TO EN-TARGET-ID(WS-ROW)
     PERFORM 10 TIMES
         CALL "ARROW-STEP" USING WS-ROW
     END-PERFORM
     MOVE "acceptance US15 44-8§7.6 with no room the arrow stays" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-USED(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-ROW
     STOP RUN.
 SPAWN-STUCK.
*>   A stuck arrow at (X0 + AX, Y + AY, Z0), age 0.
     COMPUTE WS-AX = WS-X0 + WS-AX
     COMPUTE WS-AY = WS-Y + WS-AY
     MOVE WS-Z0 TO WS-AZ
     CALL "ARROW-SPAWN" USING WS-DIM WS-AX WS-AY WS-AZ WS-ZERO-F WS-ZERO-G WS-ZERO-H WS-BASE WS-OWNER WS-ROW
     MOVE 1 TO EN-ON-GROUND(WS-ROW)
     MOVE 0 TO EN-AGE(WS-ROW).
 TEST-REACH-X.
     MOVE WS-AX TO WS-AZ
     COMPUTE WS-AX = WS-X0 + WS-AZ
     MOVE WS-Y TO WS-AY
     MOVE WS-Z0 TO WS-AZ
     CALL "ARROW-SPAWN" USING WS-DIM WS-AX WS-AY WS-AZ WS-ZERO-F WS-ZERO-G WS-ZERO-H WS-BASE WS-OWNER WS-ROW
     CALL "ARROW-IN-REACH" USING WS-PLAYER WS-ROW WS-IN
     CALL "ENTITY-REMOVE" USING WS-ROW.
 TEST-REACH-Y.
     MOVE WS-AY TO WS-AZ
     COMPUTE WS-AY = WS-Y + WS-AZ
     MOVE WS-X0 TO WS-AX
     MOVE WS-Z0 TO WS-AZ
     CALL "ARROW-SPAWN" USING WS-DIM WS-AX WS-AY WS-AZ WS-ZERO-F WS-ZERO-G WS-ZERO-H WS-BASE WS-OWNER WS-ROW
     CALL "ARROW-IN-REACH" USING WS-PLAYER WS-ROW WS-IN
     CALL "ENTITY-REMOVE" USING WS-ROW.
 COUNT-ARROWS.
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
         IF PL-SLOT-ITEM(WS-PLAYER, WS-I) = WS-ARROW-ITEM AND PL-SLOT-COUNT(WS-PLAYER, WS-I) > 0
             ADD PL-SLOT-COUNT(WS-PLAYER, WS-I) TO WS-N
         END-IF
     END-PERFORM.
 END PROGRAM TEST-Q44-44-8-PICK.

 COPY CORETEST.
 COPY MOBSPTEST.
 COPY BETEST.
