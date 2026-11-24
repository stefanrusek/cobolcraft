*> Implementation test (wrap I3, T2814/T2815; docs/protocol/44-residual-mob-questions-8-vehicles-and-projectiles.md section 11 and 20 section 4.5): a drowned that holds a trident and has a target
*> throws it. The trident attack goal has the interval 40 ticks (attackTime 40 on its first tick, the throw when it counts down to 0 with a line of sight), the thrown trident (ThrownTrident, owner the
*> drowned) is shot at speed 1.6 along the vector to the target's position at one third of its height, y plus 0.2 x the horizontal distance, with the inaccuracy 14 - 4 x difficulty id (2 at Hard).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-8-11.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY BRWORLD.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FSIZE               BINARY-LONG VALUE 20.
 01 WS-FKIND               BINARY-LONG VALUE 2.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-DROWNED             BINARY-LONG.
 01 WS-TRIDENT-ITEM        BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-H                   FLOAT-LONG.
 01 WS-LEN                 FLOAT-LONG.
 01 WS-AY                  FLOAT-LONG.
 01 WS-ERR                 FLOAT-LONG.
 01 WS-SPEED               FLOAT-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE 3 TO BW-DIFFICULTY
     MOVE 18000 TO CW-TIME
     COMPUTE WS-FX = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 10
     COMPUTE WS-FZ = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 10
     COMPUTE WS-FY = FUNCTION INTEGER(PL-Y(WS-PLAYER)) - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-FSIZE WS-FY WS-FKIND
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:trident" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-TRIDENT-ITEM WS-ITEM-ROW WS-STATUS
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:drowned" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STONE
     MOVE PL-X(WS-PLAYER) TO WS-X
     COMPUTE WS-Y = WS-FY + 1
     COMPUTE WS-Z = PL-Z(WS-PLAYER) + 6
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-DROWNED
     MOVE WS-PLAYER TO EN-TARGET(WS-DROWNED)
*>   No trident in hand: the timer stays 0 and nothing is thrown.
     MOVE 0 TO EN-HAND(WS-DROWNED)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 45
         CALL "DROWNED-TRIDENT-TICK" USING WS-DROWNED
     END-PERFORM
     PERFORM COUNT-TRIDENTS
     MOVE "acceptance US15 44-8§11 a drowned without a trident throws none and keeps no timer" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-COUNT + EN-SHOOT-TIME(WS-DROWNED)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   With a trident: attackTime 40 on the first tick, 1 after 40 ticks, the throw on the 41st.
     COMPUTE EN-HAND(WS-DROWNED) = 1000 + WS-TRIDENT-ITEM
     CALL "DROWNED-TRIDENT-TICK" USING WS-DROWNED
     MOVE "acceptance US15 44-8§11 the trident goal's attackTime is 40 on its first tick (interval 40)" TO TL-CASE
     MOVE 40 TO TL-EXPECTED-N
     MOVE EN-SHOOT-TIME(WS-DROWNED) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 39
         CALL "DROWNED-TRIDENT-TICK" USING WS-DROWNED
     END-PERFORM
     PERFORM COUNT-TRIDENTS
     MOVE "acceptance US15 44-8§11 no trident has flown after 40 ticks (attackTime 1)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-SHOOT-TIME(WS-DROWNED) + WS-COUNT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "DROWNED-TRIDENT-TICK" USING WS-DROWNED
     PERFORM COUNT-TRIDENTS
     MOVE "acceptance US15 44-8§11 the 41st tick throws one trident and starts the interval again" TO TL-CASE
     MOVE 140 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-SHOOT-TIME(WS-DROWNED) + WS-COUNT * 100
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The thrown trident: owner the drowned, speed 1.6 within the inaccuracy, aimed at one third of the player's height plus 0.2 x the distance.
     MOVE 0 TO WS-FOUND
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-IS-TRIDENT(WS-I) = 1
             MOVE WS-I TO WS-FOUND
         END-IF
     END-PERFORM
     MOVE "acceptance US15 44-8§11 the thrown trident's owner is the drowned" TO TL-CASE
     MOVE EN-ID(WS-DROWNED) TO TL-EXPECTED-N
     MOVE EN-TARGET-ID(WS-FOUND) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-AY = EN-Y(WS-DROWNED) + 1.74 - 0.1
     MOVE "acceptance US15 44-8§11 the trident starts at the drowned's eye minus 0.1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE WS-ERR = FUNCTION ABS(EN-Y(WS-FOUND) - WS-AY)
     MOVE 0 TO TL-OBSERVED-N
     IF WS-ERR < 0.001
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-DX = PL-X(WS-PLAYER) - EN-X(WS-DROWNED)
     COMPUTE WS-DZ = PL-Z(WS-PLAYER) - EN-Z(WS-DROWNED)
     COMPUTE WS-H = FUNCTION SQRT(WS-DX * WS-DX + WS-DZ * WS-DZ)
     COMPUTE WS-DY = PL-Y(WS-PLAYER) + 0.6 - WS-AY + WS-H * 0.2
     COMPUTE WS-LEN = FUNCTION SQRT(WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ)
     COMPUTE WS-SPEED = FUNCTION SQRT(EN-VX(WS-FOUND) ** 2 + EN-VY(WS-FOUND) ** 2 + EN-VZ(WS-FOUND) ** 2)
     MOVE "acceptance US15 44-8§11 the trident flies at speed 1.6 (within the inaccuracy 2 of Hard)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-SPEED > 1.5 AND WS-SPEED < 1.7
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-ERR = FUNCTION ABS(EN-VX(WS-FOUND) / 1.6 - WS-DX / WS-LEN) + FUNCTION ABS(EN-VY(WS-FOUND) / 1.6 - WS-DY / WS-LEN)
         + FUNCTION ABS(EN-VZ(WS-FOUND) / 1.6 - WS-DZ / WS-LEN)
     MOVE "acceptance US15 44-8§11 the velocity follows the aim: the player's third-height point and +0.2 x distance on y" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-ERR < 0.12
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Without a line of sight the throw does not happen at 0, and the interval starts again on the next tick.
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-PLAYER)) + 3
     COMPUTE WS-BY = WS-FY + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STONE
     COMPUTE WS-BY = WS-FY + 2
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STONE
     COMPUTE WS-BY = WS-FY + 3
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STONE
     MOVE 1 TO EN-SHOOT-TIME(WS-DROWNED)
     PERFORM COUNT-TRIDENTS
     MOVE WS-COUNT TO WS-I
     CALL "DROWNED-TRIDENT-TICK" USING WS-DROWNED
     PERFORM COUNT-TRIDENTS
     MOVE "acceptance US15 44-8§11 no line of sight at attackTime 0: nothing is thrown, the timer is 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = (WS-COUNT - WS-I) * 100 + EN-SHOOT-TIME(WS-DROWNED)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "DROWNED-TRIDENT-TICK" USING WS-DROWNED
     MOVE "acceptance US15 44-8§11 the interval starts again (40) on the next tick" TO TL-CASE
     MOVE 40 TO TL-EXPECTED-N
     MOVE EN-SHOOT-TIME(WS-DROWNED) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The mob step of a drowned runs the goal.
     COMPUTE WS-BY = WS-FY + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-AIR
     COMPUTE WS-BY = WS-FY + 2
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-AIR
     COMPUTE WS-BY = WS-FY + 3
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-AIR
     MOVE 0 TO EN-SHOOT-TIME(WS-DROWNED)
     MOVE WS-PLAYER TO EN-TARGET(WS-DROWNED)
     ADD 1 TO CW-TIME
     CALL "MOB-STEP" USING WS-DROWNED
     MOVE "acceptance US15 44-8§11 the drowned's mob step runs the trident goal (attackTime 40)" TO TL-CASE
     MOVE 40 TO TL-EXPECTED-N
     MOVE EN-SHOOT-TIME(WS-DROWNED) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 COUNT-TRIDENTS.
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-FOUND FROM 1 BY 1 UNTIL WS-FOUND > EN-COUNT
         IF EN-USED(WS-FOUND) = 1 AND EN-IS-TRIDENT(WS-FOUND) = 1
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM.
 END PROGRAM TEST-Q44-44-8-11.
 COPY CORETEST.
 COPY MOBSPTEST.
