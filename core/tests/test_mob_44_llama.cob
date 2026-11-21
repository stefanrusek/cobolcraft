*> Implementation test (002-lane-mobsa5; 44 part 4 section 2.2, 19 section 3.7, 21 section 8.14): the llama caravan and the llama's spit. A free llama near a leashed one
*> (not within 2 blocks) joins it as its tail (head and tail rows), a third joins the tail, a leashed llama never joins; the follower walks toward the head at 2.1 x the stroll
*> speed; beyond 26 blocks the speed grows by 1.2 and the distance counter is 40; when the chain no longer reaches a leashed llama the follower leaves the caravan and its speed
*> is reset. A llama hit by a player spits at it once, 41 ticks later (attack time 40), from the position in front of its body; the spit flies with gravity 0.06 and drag 0.99,
*> hurts the player by 1 and is gone.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-44-LLAMA.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY BRWORLD.
 COPY STDMOBS.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-L1                  BINARY-LONG.
 01 WS-L2                  BINARY-LONG.
 01 WS-L3                  BINARY-LONG.
 01 WS-L4                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG VALUE 40.
 01 WS-SIZE                BINARY-LONG VALUE 48.
 01 WS-STONE               BINARY-LONG VALUE 1.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-HX                  FLOAT-LONG.
 01 WS-HZ                  FLOAT-LONG.
 01 WS-WALK                BINARY-LONG.
 01 WS-SPIT-TYPE           BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-SPIT                BINARY-LONG.
 01 WS-HEALTH0             FLOAT-SHORT.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 24
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 24
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-X0 WS-Z0 WS-SIZE WS-FLOOR WS-STONE
     COMPUTE PL-X(WS-PLAYER) = WS-X0 + 4.5
     COMPUTE PL-Y(WS-PLAYER) = WS-FLOOR + 1
     COMPUTE PL-Z(WS-PLAYER) = WS-Z0 + 24.5
     MOVE "N" TO TL-MODE
     MOVE 2 TO BW-DIFFICULTY
     MOVE 6000 TO CW-TIME
     MOVE "minecraft:llama" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-Y = WS-FLOOR + 1
     COMPUTE WS-X = WS-X0 + 10.5
     COMPUTE WS-Z = WS-Z0 + 24.5
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-L1
     COMPUTE WS-X = WS-X0 + 16.5
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-L2
     COMPUTE WS-X = WS-X0 + 22.5
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-L3
     COMPUTE WS-X = WS-X0 + 40.5
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-L4
     MOVE WS-PLAYER TO EN-LEASH(WS-L1)
     MOVE 1 TO EN-ON-GROUND(WS-L1) EN-ON-GROUND(WS-L2) EN-ON-GROUND(WS-L3)

*>   The leashed llama never joins; the free one 6 blocks behind it joins as its tail.
     CALL "M44-LLAMA-TICK" USING WS-L1 WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 44§2.2 Llama caravan: a leashed llama does not join a caravan" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-LLAMA-HEAD(WS-L1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "M44-LLAMA-TICK" USING WS-L2 WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 44§2.2 Llama caravan: a free llama near a leashed one joins it (head and tail)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-L1 * 1000 + WS-L2
     COMPUTE TL-OBSERVED-N = EN-LLAMA-HEAD(WS-L2) * 1000 + EN-LLAMA-TAIL(WS-L1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44§2.2 Llama caravan: the follower walks toward its head at speed modifier 2.1" TO TL-CASE
     MOVE 2100 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(EN-LLAMA-SPEED(WS-L2) * 1000 + 0.5)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "M44-LLAMA-TICK" USING WS-L2 WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 44§2.2 Llama caravan: the follower's walk is toward the head (negative x)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-WALK = 1 AND WS-HX < 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A third llama joins the tail of the chain (a llama in a caravan with no tail comes first).
     CALL "M44-LLAMA-TICK" USING WS-L3 WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 44§2.2 Llama caravan: a third llama joins the tail of the second" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-L2 * 1000 + WS-L3
     COMPUTE TL-OBSERVED-N = EN-LLAMA-HEAD(WS-L3) * 1000 + EN-LLAMA-TAIL(WS-L2)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "M44-LLAMA-TICK" USING WS-L4 WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 44§2.2 Llama caravan: a llama beyond the 9 block box does not join" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-LLAMA-HEAD(WS-L4) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Closer than 2 blocks to the candidate: no join.
     COMPUTE EN-X(WS-L4) = EN-X(WS-L3) + 1.5
     CALL "M44-LLAMA-TICK" USING WS-L4 WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 44§2.2 Llama caravan: a candidate closer than 2 blocks is not joined" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-LLAMA-HEAD(WS-L4) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   More than 26 blocks from the head: the speed grows by 1.2, the counter is 40.
     COMPUTE EN-X(WS-L3) = EN-X(WS-L2) + 27
     CALL "M44-LLAMA-TICK" USING WS-L3 WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 44§2.2 Llama caravan: beyond 26 blocks the speed is multiplied by 1.2 and the counter is 40" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 2520 * 100 + 40
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(EN-LLAMA-SPEED(WS-L3) * 1000 + 0.5) * 100 + EN-LLAMA-DIST(WS-L3)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE EN-X(WS-L3) = EN-X(WS-L2) + 5

*>   The leader loses its lead: the chain reaches no leashed llama, the followers leave.
     MOVE 0 TO EN-LEASH(WS-L1)
     CALL "M44-LLAMA-TICK" USING WS-L2 WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 44§2.2 Llama caravan: when the chain reaches no leashed llama the follower leaves it" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-LLAMA-HEAD(WS-L2) + EN-LLAMA-TAIL(WS-L1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44§2.2 Llama caravan: the speed is reset to 2.1 on leaving" TO TL-CASE
     MOVE 2100 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(EN-LLAMA-SPEED(WS-L2) * 1000 + 0.5)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A dead head ends the caravan of the llama behind it.
     MOVE WS-PLAYER TO EN-LEASH(WS-L1)
     MOVE 0 TO EN-LLAMA-HEAD(WS-L3) EN-LLAMA-TAIL(WS-L2)
     MOVE WS-L2 TO EN-LLAMA-HEAD(WS-L3)
     MOVE WS-L3 TO EN-LLAMA-TAIL(WS-L2)
     MOVE WS-L1 TO EN-LLAMA-HEAD(WS-L2)
     MOVE WS-L2 TO EN-LLAMA-TAIL(WS-L1)
     MOVE 2.1 TO EN-LLAMA-SPEED(WS-L3)
     MOVE 0 TO EN-HEALTH(WS-L2)
     CALL "M44-LLAMA-TICK" USING WS-L3 WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 44§2.2 Llama caravan: a follower whose head is dead leaves the caravan" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-LLAMA-HEAD(WS-L3) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Within 2 blocks of its head the follower only turns; beyond 26 blocks at a speed above 3.0 the goal ends once the counter is 0.
     MOVE 20 TO EN-HEALTH(WS-L2)
     MOVE WS-L1 TO EN-LLAMA-HEAD(WS-L2)
     MOVE WS-L2 TO EN-LLAMA-TAIL(WS-L1)
     MOVE 2.1 TO EN-LLAMA-SPEED(WS-L2)
     COMPUTE EN-X(WS-L2) = EN-X(WS-L1) + 1
     CALL "M44-LLAMA-TICK" USING WS-L2 WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 44§2.2 Llama caravan: within 2 blocks of the head the follower stands (heading about zero)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-WALK = 1 AND FUNCTION ABS(WS-HX) < 0.001
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3.5 TO EN-LLAMA-SPEED(WS-L2)
     MOVE 0 TO EN-LLAMA-DIST(WS-L2)
     COMPUTE EN-X(WS-L2) = EN-X(WS-L1) + 30
     CALL "M44-LLAMA-TICK" USING WS-L2 WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 44§2.2 Llama caravan: far behind at a speed above 3.0 with the counter at 0 the goal ends" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-LLAMA-HEAD(WS-L2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Spit: the llama L4 is hit by the player (the memory of the hit is 100 ticks) and spits once after 41 ticks.
     MOVE 0 TO EN-LEASH(WS-L1)
     COMPUTE EN-X(WS-L4) = WS-X0 + 10.5
     MOVE 1 TO EN-ON-GROUND(WS-L4)
     MOVE WS-PLAYER TO EN-KILLER(WS-L4)
     MOVE 100 TO EN-KILLER-AGE(WS-L4)
     CALL "M44-LLAMA-TICK" USING WS-L4 WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 44§2.2 Llama spit: a hit by a player makes it the target, the attack time starts" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-PLAYER * 1000 + 40
     COMPUTE TL-OBSERVED-N = EN-SPIT-TGT(WS-L4) * 1000 + EN-SPIT-CD(WS-L4)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-KIND
     CALL "PROJ-TYPE" USING WS-KIND WS-SPIT-TYPE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 39
         SUBTRACT 1 FROM EN-KILLER-AGE(WS-L4)
         CALL "M44-LLAMA-TICK" USING WS-L4 WS-HX WS-HZ WS-WALK
     END-PERFORM
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-SPIT-TYPE
             ADD 1 TO WS-N
         END-IF
     END-PERFORM
     MOVE "acceptance US15 44§2.2 Llama spit: nothing is spat before the 40th tick of the attack time" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     SUBTRACT 1 FROM EN-KILLER-AGE(WS-L4)
     CALL "M44-LLAMA-TICK" USING WS-L4 WS-HX WS-HZ WS-WALK
     MOVE 0 TO WS-SPIT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-SPIT-TYPE
             MOVE WS-I TO WS-SPIT
         END-IF
     END-PERFORM
     MOVE "acceptance US15 44§2.2 Llama spit: the spit exists on the 40th tick, owned by the llama" TO TL-CASE
     MOVE EN-ID(WS-L4) TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-SPIT > 0
         MOVE EN-TARGET-ID(WS-SPIT) TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44§2.2 Llama spit: the llama gives up its target after the spit (didSpit)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-SPIT-TGT(WS-L4) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 21§8.14 Llama spit: it flies toward the player (velocity x negative, speed about 1.5)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-VX(WS-SPIT) < -1.0 AND EN-VX(WS-SPIT) > -1.6
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 20 TO PL-HEALTH(WS-PLAYER)
     MOVE PL-HEALTH(WS-PLAYER) TO WS-HEALTH0
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 30 OR EN-USED(WS-SPIT) = 0
         CALL "PROJ-STEP" USING WS-SPIT
     END-PERFORM
     MOVE "acceptance US15 21§8.14 Llama spit: the spit hurts the player by 1 and is gone" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PL-HEALTH(WS-PLAYER) = WS-HEALTH0 - 1 AND EN-TYPE(WS-SPIT) NOT = WS-SPIT-TYPE
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A target more than 40 blocks away is given up.
     MOVE WS-PLAYER TO EN-SPIT-TGT(WS-L4)
     COMPUTE EN-X(WS-L4) = PL-X(WS-PLAYER) + 45
     CALL "M44-LLAMA-TICK" USING WS-L4 WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 44§2.2 Llama spit: a target beyond 40 blocks is given up" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-SPIT-TGT(WS-L4) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-MOB-44-LLAMA.
 COPY CORETEST.
 COPY MOBSPTEST.
