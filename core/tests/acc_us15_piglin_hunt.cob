*> Acceptance test, piglins hunting hoglins (docs/protocol/21 sections 5.5.1, 5.6; lane 002-lane-mobsb5, T8911): the hunting gap of 30 to 120 s, the choice of the nearest visible adult
*> hoglin, babies and brutes spared, the melee, the hoglin fighting back with A / 2 + nextInt(A), and a kill restarting the gap.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US15-PIGLIN-HUNT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY BRWORLD.
 COPY HUNT.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-PGTYPE              BINARY-LONG.
 01 WS-HGTYPE              BINARY-LONG.
 01 WS-BRTYPE              BINARY-LONG.
 01 WS-PG                  BINARY-LONG.
 01 WS-HG                  BINARY-LONG.
 01 WS-HG2                 BINARY-LONG.
 01 WS-BR                  BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-Z0                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-SLOT                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-HX                  FLOAT-LONG.
 01 WS-HZ                  FLOAT-LONG.
 01 WS-WALK                BINARY-LONG.
 01 WS-H0                  BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "minecraft:piglin" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-PGTYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:hoglin" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-HGTYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:piglin_brute" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-BRTYPE WS-ENTITY-ROW WS-STATUS
     MOVE PL-X(WS-PLAYER) TO WS-X0
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z0
     COMPUTE WS-BX = FUNCTION INTEGER(WS-X0) - 20
     COMPUTE WS-BY = FUNCTION INTEGER(WS-Y) - 1
     COMPUTE WS-BZ = FUNCTION INTEGER(WS-Z0) - 20
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-BX WS-BZ 40 WS-BY 1
     MOVE 2 TO BW-DIFFICULTY
     MOVE 1000 TO CW-TICKS
     CALL "MOB-SPAWN" USING WS-DIM WS-PGTYPE WS-X0 WS-Y WS-Z0 WS-YAW WS-PG
     COMPUTE WS-X = WS-X0 + 5
     CALL "MOB-SPAWN" USING WS-DIM WS-HGTYPE WS-X WS-Y WS-Z0 WS-YAW WS-HG
     CALL "PIGLIN-HUNT-STEP" USING WS-PG
     MOVE 0 TO WS-SLOT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PH-MAX
         IF PH-ID(WS-I) = EN-ID(WS-PG)
             MOVE WS-I TO WS-SLOT
         END-IF
     END-PERFORM
     MOVE "acceptance US15 21§5.5.1 the first step starts a 30 to 120 s gap" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-SLOT > 0
         IF PH-TIMER(WS-SLOT) >= 599 AND PH-TIMER(WS-SLOT) <= 2399
             MOVE 1 TO TL-OBSERVED-N
         END-IF
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 21§5.5.1 no hunt during the gap" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-FOE(WS-PG) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Gap over: a baby hoglin nearer than the adult is spared, the adult is chosen.
     MOVE 0 TO PH-TIMER(WS-SLOT)
     COMPUTE WS-X = WS-X0 + 2
     CALL "MOB-SPAWN" USING WS-DIM WS-HGTYPE WS-X WS-Y WS-Z0 WS-YAW WS-HG2
     MOVE -10000 TO EN-MOBAGE(WS-HG2)
     CALL "PIGLIN-HUNT-STEP" USING WS-PG
     MOVE "acceptance US15 21§5.5.1 the nearest adult hoglin becomes the foe" TO TL-CASE
     MOVE WS-HG TO TL-EXPECTED-N
     MOVE EN-FOE(WS-PG) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A brute never hunts.
     COMPUTE WS-Z = WS-Z0 + 3
     CALL "MOB-SPAWN" USING WS-DIM WS-BRTYPE WS-X0 WS-Y WS-Z WS-YAW WS-BR
     CALL "PIGLIN-HUNT-STEP" USING WS-BR
     MOVE "acceptance US15 21§5.5.2 a brute does not hunt" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-FOE(WS-BR) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The melee: bring the hoglin into reach; the piglin hits for 5 and the hoglin turns on the piglin.
     COMPUTE EN-X(WS-HG) = EN-X(WS-PG) + 0.5
     MOVE EN-HEALTH(WS-HG) TO WS-H0
     CALL "STDMOB-INDEX" USING EN-TYPE(WS-PG) WS-M
     MOVE 0 TO EN-PET-CD(WS-PG)
     MOVE 0 TO EN-HURT(WS-HG)
     CALL "MOBVS-TICK" USING WS-PG WS-M WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 21§5.5.1 the piglin hits the hoglin for 5" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-H0 - EN-HEALTH(WS-HG)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 21§5.6 the hoglin fights back at the piglin" TO TL-CASE
     MOVE WS-PG TO TL-EXPECTED-N
     MOVE EN-FOE(WS-HG) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "STDMOB-INDEX" USING EN-TYPE(WS-HG) WS-M
     MOVE EN-HEALTH(WS-PG) TO WS-H0
     MOVE 0 TO EN-PET-CD(WS-HG)
     MOVE 0 TO EN-HURT(WS-PG)
     CALL "MOBVS-TICK" USING WS-HG WS-M WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 21§5.6 the hoglin hits for 3 to 8" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-H0 - EN-HEALTH(WS-PG) >= 3 AND WS-H0 - EN-HEALTH(WS-PG) <= 8
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A kill: the foe is cleared and the gap restarts.
     CALL "STDMOB-INDEX" USING EN-TYPE(WS-PG) WS-M
     MOVE 3 TO EN-HEALTH(WS-HG)
     MOVE 0 TO EN-HURT(WS-HG)
     MOVE 0 TO EN-PET-CD(WS-PG)
     MOVE WS-HG TO EN-FOE(WS-PG)
     MOVE EN-ID(WS-HG) TO EN-FOE-ID(WS-PG)
     MOVE 0 TO PH-TIMER(WS-SLOT)
     CALL "MOBVS-TICK" USING WS-PG WS-M WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 21§5.5.1 the hoglin is dead" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-HG) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 21§5.5.1 the piglin's foe is cleared" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-FOE(WS-PG) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 21§5.5.1 and a new gap of 30 to 120 s starts" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PH-TIMER(WS-SLOT) >= 600 AND PH-TIMER(WS-SLOT) <= 2400
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-US15-PIGLIN-HUNT.

 COPY CORETEST.
 COPY MOBSPTEST.
