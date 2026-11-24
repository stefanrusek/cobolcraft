*> Acceptance test, hostile mobs attacking villagers (docs/protocol/20 sections 4, 13.1 and 13.6; lane 002-lane-mobsb5, T8906): the zombie family, vindicators and ravagers target the
*> nearest villager or wandering trader within the follow range when no player is the target, walk to it and hit it with the attack damage on the attack timer; illagers and ravagers
*> spare babies; a zombie kill converts a villager by the difficulty rule (ZV-KILLED); a pillager is not wired (ranged).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US15-MOB-VILLAGER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY BRWORLD.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-VTYPE               BINARY-LONG.
 01 WS-ZTYPE               BINARY-LONG.
 01 WS-ZVTYPE              BINARY-LONG.
 01 WS-INTYPE              BINARY-LONG.
 01 WS-PTYPE               BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-Z0                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-HX                  FLOAT-LONG.
 01 WS-HZ                  FLOAT-LONG.
 01 WS-WALK                BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-H0                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "minecraft:villager" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-VTYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:zombie" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ZTYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:zombie_villager" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ZVTYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:vindicator" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-INTYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:pillager" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-PTYPE WS-ENTITY-ROW WS-STATUS
     MOVE PL-X(WS-PLAYER) TO WS-X0
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z0
     COMPUTE WS-BX = FUNCTION INTEGER(WS-X0) - 20
     COMPUTE WS-BY = FUNCTION INTEGER(WS-Y) - 1
     COMPUTE WS-BZ = FUNCTION INTEGER(WS-Z0) - 20
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-BX WS-BZ 40 WS-BY 1
     MOVE 1 TO BW-DIFFICULTY
     MOVE 40 TO CW-TICKS
     CALL "MOB-SPAWN" USING WS-DIM WS-VTYPE WS-X0 WS-Y WS-Z0 WS-YAW WS-V
*>   A zombie in reach hits for its attack damage (3), then waits for the timer.
     COMPUTE WS-X = WS-X0 + 0.5
     CALL "MOB-SPAWN" USING WS-DIM WS-ZTYPE WS-X WS-Y WS-Z0 WS-YAW WS-Z
     CALL "STDMOB-INDEX" USING EN-TYPE(WS-Z) WS-M
     MOVE EN-HEALTH(WS-V) TO WS-H0
     CALL "MOBVS-TICK" USING WS-Z WS-M WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 20§4 a zombie in reach hits a villager for 3" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-H0 - EN-HEALTH(WS-V)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "MOBVS-TICK" USING WS-Z WS-M WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 20§4 the attack timer holds the second hit back" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-H0 - EN-HEALTH(WS-V)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§4 a target means walking" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-WALK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A zombie 6 blocks away walks toward the villager and does not hit.
     COMPUTE EN-X(WS-Z) = WS-X0 + 6
     MOVE 0 TO EN-PET-CD(WS-Z)
     MOVE EN-HEALTH(WS-V) TO WS-H0
     CALL "MOBVS-TICK" USING WS-Z WS-M WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 20§4 out of reach it walks (west, toward the villager)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-WALK = 1 AND WS-HX < 0 AND WS-H0 = EN-HEALTH(WS-V)
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Beyond the follow range (35) there is no target.
     COMPUTE EN-X(WS-Z) = WS-X0 + 36
     CALL "MOBVS-TICK" USING WS-Z WS-M WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 20§4 beyond the follow range no target" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-WALK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A vindicator spares a baby villager; a zombie does not.
     MOVE -1000 TO EN-MOBAGE(WS-V)
     CALL "MOB-SPAWN" USING WS-DIM WS-INTYPE WS-X0 WS-Y WS-Z0 WS-YAW WS-N
     CALL "STDMOB-INDEX" USING EN-TYPE(WS-N) WS-M
     MOVE EN-HEALTH(WS-V) TO WS-H0
     CALL "MOBVS-TICK" USING WS-N WS-M WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 13 a vindicator spares a baby villager" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-WALK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EN-MOBAGE(WS-V)
     MOVE 0 TO EN-HURT(WS-V)
     CALL "MOBVS-TICK" USING WS-N WS-M WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 13.1 it hits an adult for 5" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-H0 - EN-HEALTH(WS-V)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A pillager is not wired here.
     CALL "MOB-SPAWN" USING WS-DIM WS-PTYPE WS-X0 WS-Y WS-Z0 WS-YAW WS-N
     CALL "STDMOB-INDEX" USING EN-TYPE(WS-N) WS-M
     CALL "MOBVS-TICK" USING WS-N WS-M WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 13.2 a pillager is not a melee attacker of villagers" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-WALK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Easy: the villager dies as a villager; Hard: it becomes a zombie villager.
     CALL "STDMOB-INDEX" USING EN-TYPE(WS-Z) WS-M
     COMPUTE EN-X(WS-Z) = WS-X0 + 0.5
     MOVE 0 TO EN-PET-CD(WS-Z)
     MOVE 3 TO EN-HEALTH(WS-V)
     MOVE 0 TO EN-HURT(WS-V)
     CALL "MOBVS-TICK" USING WS-Z WS-M WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 20§4 on Easy the villager dies of the hit" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-V) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO BW-DIFFICULTY
     CALL "MOB-SPAWN" USING WS-DIM WS-VTYPE WS-X0 WS-Y WS-Z0 WS-YAW WS-V
     MOVE 3 TO EN-HEALTH(WS-V)
     MOVE 0 TO EN-PET-CD(WS-Z)
     CALL "MOBVS-TICK" USING WS-Z WS-M WS-HX WS-HZ WS-WALK
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-ZVTYPE
             ADD 1 TO WS-N
         END-IF
     END-PERFORM
     MOVE "acceptance US15 20§4 on Hard the kill makes a zombie villager" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-US15-MOB-VILLAGER.

 COPY CORETEST.
 COPY MOBSPTEST.
