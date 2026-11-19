*> The arrow family (docs/protocol/17 section 3.9 and 3.10, 21 section 8.17.1, 44-8 section 10; lane p49t, T39020): spectral_arrow and trident are arrow entities (ARROW-SPAWN-AS family 2 and 3, stepped by
*> ARROWS-TICK like arrows). A spectral arrow hurts like an arrow (ceil(speed x base damage)) and gives a hit player Glowing (effect 23) for 200 ticks. A thrown trident hurts 8.0 whatever its speed, is not
*> removed by the hit, bounces back with the velocity (vx x -0.01, vy x -0.1, vz x -0.01) and hits nothing more once it has dealt damage.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-P49T-ARROW-FAMILY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY EFFECTS.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-ARROW               BINARY-LONG.
 01 WS-FAMILY              BINARY-LONG.
 01 WS-TYPE1               BINARY-LONG.
 01 WS-TYPE2               BINARY-LONG.
 01 WS-TYPE3               BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-VX                  FLOAT-LONG.
 01 WS-VY                  FLOAT-LONG VALUE 0.
 01 WS-VZ                  FLOAT-LONG VALUE 0.
 01 WS-BASE                BINARY-LONG.
 01 WS-OWNER               BINARY-LONG VALUE 0.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-LOST                BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE 1 TO WS-FAMILY
     CALL "ARROW-FAMILY-TYPE" USING WS-FAMILY WS-TYPE1
     MOVE 2 TO WS-FAMILY
     CALL "ARROW-FAMILY-TYPE" USING WS-FAMILY WS-TYPE2
     MOVE 3 TO WS-FAMILY
     CALL "ARROW-FAMILY-TYPE" USING WS-FAMILY WS-TYPE3
     MOVE "acceptance US15 17§3.9 the three members of the arrow family have three different entity types" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-TYPE1 > 0 AND WS-TYPE2 > 0 AND WS-TYPE3 > 0 AND WS-TYPE1 NOT = WS-TYPE2 AND WS-TYPE2 NOT = WS-TYPE3
             AND WS-TYPE1 NOT = WS-TYPE3
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-PLAYER)) + 4
     COMPUTE WS-BY = FUNCTION INTEGER(PL-Y(WS-PLAYER)) + 40
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-X0 = WS-BX + 0.5
     MOVE WS-BY TO WS-Y
     COMPUTE WS-Z = WS-BZ + 0.5
     MOVE 1.6 TO WS-VX
     MOVE 2000 TO WS-BASE
*>   A spectral arrow flies like an arrow.
     MOVE 2 TO WS-FAMILY
     CALL "ARROW-SPAWN-AS" USING WS-FAMILY WS-DIM WS-X0 WS-Y WS-Z WS-VX WS-VY WS-VZ WS-BASE WS-OWNER WS-ARROW
     MOVE "acceptance US15 17§3.9 the spectral arrow row has the spectral_arrow type" TO TL-CASE
     MOVE WS-TYPE2 TO TL-EXPECTED-N
     MOVE EN-TYPE(WS-ARROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ARROWS-TICK"
     MOVE "acceptance US15 17§3.9 a spectral arrow moves by its velocity (1.6) in a tick (tenths of a millionth)" TO TL-CASE
     MOVE 16000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = (EN-X(WS-ARROW) - WS-X0) * 10000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-ARROW
*>   A spectral arrow hits the player: 4 points and Glowing for 200 ticks.
     COMPUTE PL-X(WS-PLAYER) = WS-BX + 10.5
     MOVE WS-BY TO PL-Y(WS-PLAYER)
     MOVE WS-Z TO PL-Z(WS-PLAYER)
     MOVE 20 TO PL-HEALTH(WS-PLAYER)
     MOVE 0 TO PL-HURT-COOLDOWN(WS-PLAYER)
     COMPUTE WS-Y = WS-BY + 0.9
     COMPUTE WS-X = WS-BX + 8.5
     CALL "ARROW-SPAWN-AS" USING WS-FAMILY WS-DIM WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ WS-BASE WS-OWNER WS-ARROW
     PERFORM 3 TIMES
         CALL "ARROWS-TICK"
     END-PERFORM
     COMPUTE WS-LOST = 20 - PL-HEALTH(WS-PLAYER)
     MOVE "acceptance US15 17§3.9 a spectral arrow hurts like an arrow: ceil(1.6 x 2.0) = 4" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE WS-LOST TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 17§3.9 the spectral arrow is removed by the hit" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-USED(WS-ARROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 17§3.9 the player has Glowing (23)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EF-ON(WS-PLAYER, 24) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 17§3.9 Glowing lasts 200 ticks" TO TL-CASE
     MOVE 200 TO TL-EXPECTED-N
     MOVE EF-DURATION(WS-PLAYER, 24) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A trident hits the player: 8 points whatever the speed (2.5), it stays, bounces back and hits nothing more.
     MOVE 20 TO PL-HEALTH(WS-PLAYER)
     MOVE 0 TO PL-HURT-COOLDOWN(WS-PLAYER)
     MOVE 3 TO WS-FAMILY
     MOVE 2.5 TO WS-VX
     MOVE 8000 TO WS-BASE
     COMPUTE WS-X = WS-BX + 8.5
     CALL "ARROW-SPAWN-AS" USING WS-FAMILY WS-DIM WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ WS-BASE WS-OWNER WS-ARROW
     PERFORM 3 TIMES
         CALL "ARROWS-TICK"
     END-PERFORM
     COMPUTE WS-LOST = 20 - PL-HEALTH(WS-PLAYER)
     MOVE "acceptance US15 44-8§10 a thrown trident hurts 8 whatever its speed" TO TL-CASE
     MOVE 8 TO TL-EXPECTED-N
     MOVE WS-LOST TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-8§10 the trident is not removed by the hit" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-USED(WS-ARROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-8§10 REVERSE flips the sign of the velocity (vx now negative)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-VX(WS-ARROW) < 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-8§10 REVERSE cuts the horizontal speed to 1 percent (about 0.025 before the drag)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF FUNCTION ABS(EN-VX(WS-ARROW)) < 0.03
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 20 TO PL-HEALTH(WS-PLAYER)
     MOVE 0 TO PL-HURT-COOLDOWN(WS-PLAYER)
     MOVE PL-X(WS-PLAYER) TO EN-X(WS-ARROW)
     MOVE WS-Y TO EN-Y(WS-ARROW)
     MOVE 0.1 TO EN-VX(WS-ARROW)
     MOVE 0 TO EN-VY(WS-ARROW)
     PERFORM 3 TIMES
         CALL "ARROWS-TICK"
     END-PERFORM
     MOVE "acceptance US15 44-8§10 a trident that dealt damage finds no entity to hit again" TO TL-CASE
     MOVE 20 TO TL-EXPECTED-N
     MOVE PL-HEALTH(WS-PLAYER) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-P49T-ARROW-FAMILY.
 COPY CORETEST.
 COPY MOBSPTEST.
