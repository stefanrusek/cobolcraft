*> Acceptance test (lane p49r; docs/protocol/20 section 13.4): the goals that give a vex its wanted point. The charge starts a move to the target's eye (modifier 1.0) and, within 3 blocks of the
*> target, aims at the eye again; the random move goal (no wish, a 1 in 7 draw) picks a block within (-7..7, -5..5, -7..7) of the bound origin, an empty one of up to 3 tries, at modifier 0.25 (and
*> with only solid blocks around it picks nothing); an evoker's summon binds each vex to the block it appeared in.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-20-13-4-GOALS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY EVKSTATE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-VEX-TYPE            BINARY-LONG.
 01 WS-EVOKER-TYPE         BINARY-LONG.
 01 WS-VEX                 BINARY-LONG.
 01 WS-EVOKER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-IX                  BINARY-LONG.
 01 WS-IY                  BINARY-LONG.
 01 WS-IZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-FIRED               BINARY-LONG.
 01 WS-INSIDE              BINARY-LONG.
 01 WS-BOUND-OK            BINARY-LONG.
 01 WS-SEEN                BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-HOLD-X              FLOAT-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "N" TO TL-MODE
     MOVE "minecraft:vex" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-VEX-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:evoker" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-EVOKER-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STONE
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-BY = FUNCTION INTEGER(PL-Y(WS-PLAYER)) + 30
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE 16001 TO CW-TIME
     COMPUTE WS-X = WS-BX + 0.5
     COMPUTE WS-Y = WS-BY + 0.5
     COMPUTE WS-Z = WS-BZ + 0.5
     CALL "MOB-SPAWN" USING WS-DIM WS-VEX-TYPE WS-X WS-Y WS-Z WS-YAW WS-VEX
     MOVE 0 TO VX-ID(1)
     MOVE EN-ID(WS-VEX) TO VX-ID(1)
     MOVE 0 TO VX-OWNER(1) VX-LIFE(1) VX-STARVE(1) VX-CHARGING(1) VX-BOUND(1) VX-BX(1) VX-BY(1) VX-BZ(1)
*>   1. The charge: a player 8 blocks along +x of the vex, standing at the vex's height minus 1.62.
     COMPUTE PL-X(WS-PLAYER) = WS-X + 8
     COMPUTE PL-Y(WS-PLAYER) = WS-Y - 1.62
     MOVE WS-Z TO PL-Z(WS-PLAYER)
     MOVE WS-PLAYER TO EN-TARGET(WS-VEX)
     MOVE 0 TO EN-FLY-ON(WS-VEX)
     CALL "VEX-CHARGE" USING WS-VEX
     MOVE "acceptance US15 20§13.4 the charge wants the target's eye: x (thousandths)" TO TL-CASE
     COMPUTE TL-EXPECTED-N ROUNDED = PL-X(WS-PLAYER) * 1000
     COMPUTE TL-OBSERVED-N ROUNDED = EN-FLY-X(WS-VEX) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§13.4 the charge wants the target's eye: y is 1.62 above its feet (thousandths)" TO TL-CASE
     COMPUTE TL-EXPECTED-N ROUNDED = (PL-Y(WS-PLAYER) + 1.62) * 1000
     COMPUTE TL-OBSERVED-N ROUNDED = EN-FLY-Y(WS-VEX) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§13.4 the charge moves at modifier 1.0 and the wish is set" TO TL-CASE
     MOVE 2000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-FLY-MOD(WS-VEX) * 1000 + EN-FLY-ON(WS-VEX) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   2. Within 3 blocks of the target the charge aims at its eye again; farther it keeps its wish.
     COMPUTE PL-X(WS-PLAYER) = EN-X(WS-VEX) + 4
     MOVE 77 TO EN-FLY-X(WS-VEX)
     CALL "VEX-CONTACT" USING WS-VEX
     MOVE "acceptance US15 20§13.4 charging 4 blocks (and 1.62 up) from the target keeps its wish" TO TL-CASE
     MOVE 77000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-FLY-X(WS-VEX) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE PL-X(WS-PLAYER) = EN-X(WS-VEX) + 2.0
     CALL "VEX-CONTACT" USING WS-VEX
     MOVE "acceptance US15 20§13.4 charging within 3 blocks (2.0 along x, 1.62 up: 6.6 squared) of the target aims at its eye again (thousandths)" TO TL-CASE
     COMPUTE TL-EXPECTED-N ROUNDED = PL-X(WS-PLAYER) * 1000
     COMPUTE TL-OBSERVED-N ROUNDED = EN-FLY-X(WS-VEX) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   3. The random move: a box of air around the bound origin; the origin is the block of the vex (VX-BOUND 0) or the bound block.
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE 0 TO VX-CHARGING(1) EN-TARGET(WS-VEX)
     PERFORM CLEAR-BOX
     MOVE 0 TO EN-FLY-ON(WS-VEX)
     MOVE 0 TO WS-FIRED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 200 OR WS-FIRED = 1
         CALL "VEX-RANDOM-MOVE" USING WS-VEX
         IF EN-FLY-ON(WS-VEX) = 1
             MOVE 1 TO WS-FIRED
         END-IF
     END-PERFORM
     MOVE "acceptance US15 20§13.4 the random move fires within 200 tries (1 in 7)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FIRED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§13.4 the random move goes at modifier 0.25" TO TL-CASE
     MOVE 250 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-FLY-MOD(WS-VEX) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-INSIDE
     IF EN-FLY-X(WS-VEX) >= WS-BX - 7 AND EN-FLY-X(WS-VEX) <= WS-BX + 8 AND EN-FLY-Y(WS-VEX) >= WS-BY - 5 AND EN-FLY-Y(WS-VEX) <= WS-BY + 6
             AND EN-FLY-Z(WS-VEX) >= WS-BZ - 7 AND EN-FLY-Z(WS-VEX) <= WS-BZ + 8
         MOVE 1 TO WS-INSIDE
     END-IF
     MOVE "acceptance US15 20§13.4 the random point is within (-7..7, -5..5, -7..7) of the vex's block" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-INSIDE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   With a wish pending the goal does nothing.
     MOVE EN-FLY-X(WS-VEX) TO WS-HOLD-X
     PERFORM 50 TIMES
         CALL "VEX-RANDOM-MOVE" USING WS-VEX
     END-PERFORM
     MOVE "acceptance US15 20§13.4 with a wish pending the random move picks no new point" TO TL-CASE
     COMPUTE TL-EXPECTED-N ROUNDED = WS-HOLD-X * 1000
     COMPUTE TL-OBSERVED-N ROUNDED = EN-FLY-X(WS-VEX) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A bound origin 40 blocks east: the point is around that block.
     COMPUTE VX-BX(1) = WS-BX + 40
     MOVE WS-BY TO VX-BY(1)
     MOVE WS-BZ TO VX-BZ(1)
     MOVE 1 TO VX-BOUND(1)
     MOVE WS-BX TO WS-N
     COMPUTE WS-BX = WS-BX + 40
     PERFORM CLEAR-BOX
     MOVE WS-N TO WS-BX
     MOVE 0 TO EN-FLY-ON(WS-VEX) WS-FIRED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 200 OR WS-FIRED = 1
         CALL "VEX-RANDOM-MOVE" USING WS-VEX
         IF EN-FLY-ON(WS-VEX) = 1
             MOVE 1 TO WS-FIRED
         END-IF
     END-PERFORM
     MOVE "acceptance US15 20§13.4 a vex bound to a block picks its point around the bound origin, not around itself" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-FIRED = 1 AND EN-FLY-X(WS-VEX) >= WS-BX + 33 AND EN-FLY-X(WS-VEX) <= WS-BX + 48
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Only solid blocks around the origin: three tries, no point.
     MOVE WS-BX TO WS-N
     COMPUTE WS-BX = WS-BX + 40
     PERFORM FILL-BOX
     MOVE WS-N TO WS-BX
     MOVE 0 TO EN-FLY-ON(WS-VEX)
     PERFORM 150 TIMES
         CALL "VEX-RANDOM-MOVE" USING WS-VEX
     END-PERFORM
     MOVE "acceptance US15 20§13.4 with only solid blocks around the origin the random move picks no point" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-FLY-ON(WS-VEX) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-VEX
     MOVE 0 TO VX-ID(1)
*>   4. An evoker's summon binds each vex to the block it appeared in.
     MOVE 0 TO PL-MODE(WS-PLAYER)
     CALL "MOB-SPAWN" USING WS-DIM WS-EVOKER-TYPE WS-X WS-Y WS-Z WS-YAW WS-EVOKER
     CALL "EVK-SUMMON" USING WS-EVOKER
     MOVE 0 TO WS-SEEN WS-BOUND-OK
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > VX-MAX
         IF VX-ID(WS-I) > 0
             ADD 1 TO WS-SEEN
             PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > EN-COUNT
                 IF EN-USED(WS-J) = 1 AND EN-ID(WS-J) = VX-ID(WS-I)
                     COMPUTE WS-IX = FUNCTION INTEGER(EN-X(WS-J))
                     COMPUTE WS-IY = FUNCTION INTEGER(EN-Y(WS-J))
                     COMPUTE WS-IZ = FUNCTION INTEGER(EN-Z(WS-J))
                     IF VX-BOUND(WS-I) = 1 AND VX-BX(WS-I) = WS-IX AND VX-BY(WS-I) = WS-IY AND VX-BZ(WS-I) = WS-IZ
                         ADD 1 TO WS-BOUND-OK
                     END-IF
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
     MOVE "acceptance US15 20§13.4 the evoker's three vexes are bound to the block they appeared in" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE WS-BOUND-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   5. A whole mob step: a charging vex flies 6 blocks through the move control and hurts a survival player once (4 on Normal), the charge ending.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > VX-MAX
         IF VX-ID(WS-I) > 0
             MOVE 0 TO VX-ID(WS-I)
         END-IF
     END-PERFORM
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE 20 TO PL-HEALTH(WS-PLAYER)
     MOVE 0 TO PL-HURT-COOLDOWN(WS-PLAYER)
     CALL "MOB-SPAWN" USING WS-DIM WS-VEX-TYPE WS-X WS-Y WS-Z WS-YAW WS-VEX
     MOVE EN-ID(WS-VEX) TO VX-ID(1)
     MOVE 0 TO VX-OWNER(1) VX-LIFE(1) VX-STARVE(1) VX-CHARGING(1) VX-BOUND(1)
     COMPUTE PL-X(WS-PLAYER) = WS-X + 6
     COMPUTE PL-Y(WS-PLAYER) = WS-Y - 1.62
     MOVE WS-Z TO PL-Z(WS-PLAYER)
     MOVE WS-PLAYER TO EN-TARGET(WS-VEX)
     MOVE PL-ENTITY-ID(WS-PLAYER) TO EN-TARGET-ID(WS-VEX)
     MOVE 5 TO EN-WAKE(WS-VEX)
     CALL "VEX-CHARGE" USING WS-VEX
     PERFORM 24 TIMES
         CALL "MOB-STEP" USING WS-VEX
     END-PERFORM
     MOVE "acceptance US15 20§13.4 a charging vex flew to its target in a mob step and hurt it once for 4" TO TL-CASE
     MOVE 16000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = PL-HEALTH(WS-PLAYER) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§13.4 and the charge has ended" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE VX-CHARGING(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> Air in the box (-7..7, -5..5, -7..7) around (WS-BX, WS-BY, WS-BZ) and one block more around it.
 CLEAR-BOX.
     MOVE WS-AIR TO WS-STATE
     PERFORM PUT-BOX
     .

 FILL-BOX.
     MOVE WS-STONE TO WS-STATE
     PERFORM PUT-BOX
     .

 PUT-BOX.
     PERFORM VARYING WS-DX FROM -8 BY 1 UNTIL WS-DX > 8
         PERFORM VARYING WS-DY FROM -6 BY 1 UNTIL WS-DY > 6
             PERFORM VARYING WS-DZ FROM -8 BY 1 UNTIL WS-DZ > 8
                 COMPUTE WS-IX = WS-BX + WS-DX
                 COMPUTE WS-IY = WS-BY + WS-DY
                 COMPUTE WS-IZ = WS-BZ + WS-DZ
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-IX WS-IY WS-IZ WS-STATE
             END-PERFORM
         END-PERFORM
     END-PERFORM
     .
 END PROGRAM TEST-MOB-20-13-4-GOALS.
 COPY CORETEST.
 COPY MOBSPTEST.
