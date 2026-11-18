 *> Acceptance test (US15, FR-036; docs/protocol/44-residual-mob-questions-3-villagers-poi-raids.md section 1.7 and 44-residual-mob-questions-2-spawning-structures.md sections 6 and 13): the
 *> zombie village siege. A bright sky or a false spawn-enemies flag resets it; at the clock marker 18000 (every day) it becomes SIEGE_TONIGHT with probability 1 in 10 (nextInt(10) == 0); a
 *> setup needs a player who is not a spectator and stands in a village; it chooses a ring point 32 blocks out and sets 20 zombies and nextSpawnTime 0; then one zombie is placed within 8 blocks of
 *> the ring point (inside the village) on the first call and every third call after, and the state returns to SIEGE_DONE after the twentieth.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-2-13.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY VILPOIX.
 COPY CUSTOMSP.
 COPY XORO.
 01 WS-CASE                PIC X(240).
 01 WS-E                   BINARY-DOUBLE.
 01 WS-O                   BINARY-DOUBLE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-SIZE                BINARY-LONG VALUE 112.
 01 WS-STONE-KIND          BINARY-LONG VALUE 1.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ZOMBIE-TYPE         BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ZOMBIES             BINARY-LONG.
 01 WS-ENEMIES             BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 20260615.
 01 WS-TEN                 BINARY-LONG VALUE 10.
 01 WS-DRAW                BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-MISMATCH            BINARY-LONG.
 01 WS-ROLLED              BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-D2                  BINARY-LONG.
 01 WS-INSIDE              BINARY-LONG.
 01 WS-PLACED              BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-PX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-PY = FUNCTION INTEGER(PL-Y(WS-PLAYER))
     COMPUTE WS-PZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-FX = WS-PX - 56
     COMPUTE WS-FZ = WS-PZ - 56
     COMPUTE WS-FY = WS-PY - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-SIZE WS-FY WS-STONE-KIND
     MOVE "minecraft:zombie" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ZOMBIE-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE 1 TO WS-ENEMIES
     PERFORM CLEAR-ALL

*>   by day a siege that was running is reset
     MOVE 1 TO CSP-SG-STATE CSP-SG-SETUP
     MOVE 6000 TO CW-TIME
     CALL "SIEGE-TICK" USING WS-ENEMIES
     MOVE "acceptance US15 44-3§1.7 step 1: a bright sky resets the state and the setup flag" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O = CSP-SG-STATE + CSP-SG-SETUP
     PERFORM CHECK-N
*>   at night with the flag false likewise
     MOVE 1 TO CSP-SG-STATE CSP-SG-SETUP
     MOVE 18001 TO CW-TIME
     MOVE 0 TO WS-ENEMIES
     CALL "SIEGE-TICK" USING WS-ENEMIES
     MOVE "acceptance US15 44-3§1.7 step 1: a false spawn-enemies flag resets the state and the setup flag" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O = CSP-SG-STATE + CSP-SG-SETUP
     PERFORM CHECK-N
     MOVE 1 TO WS-ENEMIES

*>   not at the marker: no roll
     MOVE 18001 TO CW-TIME
     CALL "SIEGE-TICK" USING WS-ENEMIES
     MOVE "acceptance US15 44-3§1.7 step 2: off the marker tick 18001 the state stays SIEGE_DONE" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE CSP-SG-STATE TO WS-O
     PERFORM CHECK-N

*>   at the marker, in a village-less world: each call is one roll (nextInt(10) == 0); a state of 1 stays until a day with a miss
*>   (nothing sets one up: no player stands in a village), so the expected state of call n is the n-th draw of the generator seeded as the spawner
     CALL "XORO-SEED" USING WS-SEED XR-STATE
     MOVE 0 TO WS-MISMATCH WS-ROLLED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 300
         MOVE 24000 TO CW-TIME
         ADD 18000 TO CW-TIME
         CALL "SIEGE-TICK" USING WS-ENEMIES
         CALL "XORO-NEXT-INT" USING XR-STATE WS-TEN WS-DRAW
         MOVE 0 TO WS-WANT
         IF WS-DRAW = 0
             MOVE 1 TO WS-WANT
             ADD 1 TO WS-ROLLED
         END-IF
         IF CSP-SG-STATE NOT = WS-WANT
             ADD 1 TO WS-MISMATCH
         END-IF
     END-PERFORM
     MOVE "acceptance US15 44-3§1.7 step 2: at 18000 mod 24000 every call rolls nextInt(10) == 0 (300 rolls, each call's state as the draw says)" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-MISMATCH TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 44-3§1.7 step 2: the roll came up SIEGE_TONIGHT some of the time and missed most (1 in 10)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-ROLLED > 5 AND WS-ROLLED < 80
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N

*>   a village: a lattice of points of interest every 16 blocks covers the ring
     PERFORM VARYING WS-A FROM -4 BY 1 UNTIL WS-A > 4
         PERFORM VARYING WS-B FROM -4 BY 1 UNTIL WS-B > 4
             COMPUTE WS-I = (WS-A + 4) * 9 + WS-B + 5
             MOVE 1 TO PX-KIND(WS-I)
             MOVE WS-DIM TO PX-DIM(WS-I)
             COMPUTE PX-X(WS-I) = WS-PX + WS-A * 16
             MOVE WS-PY TO PX-Y(WS-I)
             COMPUTE PX-Z(WS-I) = WS-PZ + WS-B * 16
         END-PERFORM
     END-PERFORM

*>   a spectator does not start a siege
     MOVE 3 TO PL-MODE(WS-PLAYER)
     MOVE 1 TO CSP-SG-STATE
     MOVE 0 TO CSP-SG-SETUP
     MOVE 18001 TO CW-TIME
     CALL "SIEGE-TICK" USING WS-ENEMIES
     PERFORM COUNT-ZOMBIES
     MOVE "acceptance US15 44-3§1.7 step 4a: a spectator in the village sets nothing up: no zombie, no setup" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O = WS-ZOMBIES + CSP-SG-SETUP
     PERFORM CHECK-N
     MOVE 0 TO PL-MODE(WS-PLAYER)

*>   a player outside every village does not either: move the points of interest away
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 81
         ADD 1000 TO PX-X(WS-I)
     END-PERFORM
     CALL "SIEGE-TICK" USING WS-ENEMIES
     PERFORM COUNT-ZOMBIES
     MOVE "acceptance US15 44-3§1.7 step 4a: a player who is not in a village sets nothing up" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O = WS-ZOMBIES + CSP-SG-SETUP
     PERFORM CHECK-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 81
         SUBTRACT 1000 FROM PX-X(WS-I)
     END-PERFORM

*>   the setup call: 20 zombies to spawn, nextSpawnTime 0 so the first one is tried at once. Whether a zombie is placed also depends on the spot passing the
*>   monster light test of 18 (a random draw), "none found" only skips the placement (4b), so the counters are exact and the placed zombies are counted.
     CALL "SIEGE-TICK" USING WS-ENEMIES
     PERFORM COUNT-ZOMBIES
     MOVE WS-ZOMBIES TO WS-PLACED
     MOVE "acceptance US15 44-3§1.7 step 4 and 5: the setup call sets the siege up" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE CSP-SG-SETUP TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 44-3§1.7 step 5: nextSpawnTime was 0, so a zombie is tried at once: 19 are left, nextSpawnTime is 2, at most one is placed" TO WS-CASE
     MOVE 1902 TO WS-E
     COMPUTE WS-O = CSP-SG-ZOMBIES * 100 + CSP-SG-NEXT
     IF WS-ZOMBIES > 1
         ADD 1000 TO WS-O
     END-IF
     PERFORM CHECK-N
     COMPUTE WS-DX = CSP-SG-X - WS-PX
     COMPUTE WS-DZ = CSP-SG-Z - WS-PZ
     COMPUTE WS-D2 = WS-DX * WS-DX + WS-DZ * WS-DZ
     MOVE "acceptance US15 44-3§1.7 step 4a: the centre is the player's cell shifted by floor(cos a x 32), floor(sin a x 32): between 30 and 33 blocks out, at the player's y" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-D2 >= 900 AND WS-D2 <= 1089 AND CSP-SG-Y = WS-PY
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
*>   one zombie every third call: the calls in between change neither the zombies left nor the zombies placed, and the third places at most one
     MOVE 0 TO WS-BAD
     MOVE 19 TO WS-LEFT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 57
         CALL "SIEGE-TICK" USING WS-ENEMIES
         PERFORM COUNT-ZOMBIES
         COMPUTE WS-WANT = FUNCTION MOD(WS-I, 3)
         IF WS-WANT = 0
             SUBTRACT 1 FROM WS-LEFT
             IF WS-ZOMBIES < WS-PLACED OR WS-ZOMBIES > WS-PLACED + 1
                 ADD 1 TO WS-BAD
             END-IF
         ELSE
             IF WS-ZOMBIES NOT = WS-PLACED
                 ADD 1 TO WS-BAD
             END-IF
         END-IF
         IF CSP-SG-ZOMBIES NOT = WS-LEFT
             ADD 1 TO WS-BAD
         END-IF
         MOVE WS-ZOMBIES TO WS-PLACED
     END-PERFORM
     MOVE "acceptance US15 44-3§1.7 step 5: over 57 calls the counter drops by one on every third call only and no call places more than one zombie" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-BAD TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 44-3§1.7: all twenty were tried (none left, still SIEGE_TONIGHT) and nearly all found a spot (at least 15 stand)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF CSP-SG-ZOMBIES = 0 AND CSP-SG-STATE = 1 AND WS-ZOMBIES >= 15 AND WS-ZOMBIES <= 20
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
*>   every zombie stands within -8 to +7 blocks of the centre in x and z, on the floor
     MOVE 1 TO WS-INSIDE
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > EN-COUNT
         IF EN-USED(WS-ROW) = 1 AND EN-TYPE(WS-ROW) = WS-ZOMBIE-TYPE AND EN-PLAYER(WS-ROW) = 0
             COMPUTE WS-DX = FUNCTION INTEGER(EN-X(WS-ROW)) - CSP-SG-X
             COMPUTE WS-DZ = FUNCTION INTEGER(EN-Z(WS-ROW)) - CSP-SG-Z
             IF WS-DX < -8 OR WS-DX > 7 OR WS-DZ < -8 OR WS-DZ > 7 OR FUNCTION INTEGER(EN-Y(WS-ROW)) NOT = WS-PY
                 MOVE 0 TO WS-INSIDE
             END-IF
         END-IF
     END-PERFORM
     MOVE "acceptance US15 44-3§1.7 step 4c: every zombie stands within -8 to +7 blocks of the centre in x and z, on the floor" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-INSIDE TO WS-O
     PERFORM CHECK-N
*>   the next call after the countdown (two calls count down, the third finds nothing left) ends the siege
     MOVE WS-ZOMBIES TO WS-PLACED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         CALL "SIEGE-TICK" USING WS-ENEMIES
     END-PERFORM
     PERFORM COUNT-ZOMBIES
     MOVE "acceptance US15 44-3§1.7 step 5: with none left the state goes to SIEGE_DONE after the countdown and no twenty-first is placed" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O = CSP-SG-STATE + WS-ZOMBIES - WS-PLACED
     PERFORM CHECK-N
     STOP RUN.
 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 CLEAR-ALL.
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > EN-COUNT
         IF EN-USED(WS-ROW) = 1 AND EN-PLAYER(WS-ROW) = 0
             CALL "ENTITY-REMOVE" USING WS-ROW
         END-IF
     END-PERFORM.
 COUNT-ZOMBIES.
     MOVE 0 TO WS-ZOMBIES
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > EN-COUNT
         IF EN-USED(WS-ROW) = 1 AND EN-TYPE(WS-ROW) = WS-ZOMBIE-TYPE AND EN-PLAYER(WS-ROW) = 0
             ADD 1 TO WS-ZOMBIES
         END-IF
     END-PERFORM.
 END PROGRAM TEST-Q44-44-2-13.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY NOSPAWN.
