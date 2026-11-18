*> Acceptance test (002-lane-p49b fork u; docs/protocol/20 sections 9.1 and 9.2): the rules around the silverfish and the infested blocks. Breaking an infested block lets a silverfish out
*> unless the tool has silk touch or the block_drops rule is off; the wake-up friends scan turns an infested block into its host block (no silverfish) while the mob_griefing rule
*> is off; merge with stone (no target, mob_griefing on, nextInt(10) = 0 a tick) turns a host block next to it into the infested block and discards the silverfish; the host to
*> infested map (stone to infested_stone, ...) is read in both directions.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-20-9-3.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY CBLOCKS.
 COPY STDMOBS.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-INFESTED            BINARY-LONG.
 01 WS-DIRT                BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-COUNT               BINARY-LONG.
 01 WS-BEFORE              BINARY-LONG.
 01 WS-ITEM-ID             BINARY-LONG.
 01 WS-ENCH-ID             BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG VALUE 1.
 01 WS-HANDLE              BINARY-LONG.
 01 WS-RULE-NAME           PIC X(40).
 01 WS-RULE-INDEX          BINARY-LONG.
 01 WS-RULE-VALUE          BINARY-DOUBLE.
 01 WS-SKY                 BINARY-LONG VALUE 0.
 01 WS-HOST                BINARY-LONG.
 01 WS-MADE                BINARY-LONG.
 01 WS-DAMAGE              BINARY-LONG VALUE 1.
 01 WS-J                   BINARY-LONG.
 01 WS-MERGES              BINARY-LONG.
 01 WS-CAUSE               BINARY-LONG VALUE 3.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "N" TO TL-MODE
     MOVE "minecraft:silverfish" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:infested_stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-INFESTED
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STONE
     MOVE "minecraft:dirt" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-DIRT

*>   The host to infested map, both ways.
     MOVE CB-S-BLOCK(WS-INFESTED + 1) TO WS-BLOCK
     CALL "STDMOB-HOST-STATE" USING WS-BLOCK WS-HOST
     MOVE "acceptance US15 20§9.2 the host of infested_stone is stone" TO TL-CASE
     MOVE WS-STONE TO TL-EXPECTED-N
     MOVE WS-HOST TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE CB-S-BLOCK(WS-STONE + 1) TO WS-BLOCK
     CALL "STDMOB-INFESTED-STATE" USING WS-BLOCK WS-MADE
     MOVE "acceptance US15 20§9.2 the infested block of stone is infested_stone" TO TL-CASE
     MOVE WS-INFESTED TO TL-EXPECTED-N
     MOVE WS-MADE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE CB-S-BLOCK(WS-DIRT + 1) TO WS-BLOCK
     CALL "STDMOB-INFESTED-STATE" USING WS-BLOCK WS-MADE
     MOVE "acceptance US15 20§9.2 dirt has no infested block" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-MADE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "STDMOB-HOST-STATE" USING WS-BLOCK WS-HOST
     MOVE "acceptance US15 20§9.2 dirt is no infested block: no host" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-HOST TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Breaking an infested block: a silverfish, but not with silk touch and not without block_drops.
     MOVE CB-S-BLOCK(WS-INFESTED + 1) TO WS-BLOCK
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-PLAYER)) + 4
     COMPUTE WS-BY = FUNCTION INTEGER(PL-Y(WS-PLAYER))
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     PERFORM COUNT-SILVERFISH
     MOVE WS-COUNT TO WS-BEFORE
     CALL "STDMOB-INFESTED-BREAK" USING WS-DIM WS-BX WS-BY WS-BZ WS-BLOCK WS-PLAYER
     PERFORM COUNT-SILVERFISH
     MOVE "acceptance US15 20§9.2 an infested block broken by a bare hand lets a silverfish out" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-BEFORE + 1
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-COUNT TO WS-BEFORE
     MOVE "block_drops" TO WS-RULE-NAME
     CALL "BR-RULE-FIND" USING WS-RULE-NAME WS-RULE-INDEX
     MOVE 0 TO WS-RULE-VALUE
     CALL "BR-RULE-SET" USING WS-RULE-INDEX WS-RULE-VALUE
     CALL "STDMOB-INFESTED-BREAK" USING WS-DIM WS-BX WS-BY WS-BZ WS-BLOCK WS-PLAYER
     PERFORM COUNT-SILVERFISH
     MOVE "acceptance US15 20§9.2 the block_drops rule off stops the silverfish" TO TL-CASE
     MOVE WS-BEFORE TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-RULE-VALUE
     CALL "BR-RULE-SET" USING WS-RULE-INDEX WS-RULE-VALUE

*>   Wake-up friends with mob_griefing off: the infested block becomes its host block, no silverfish.
     COMPUTE WS-X = WS-BX + 0.5
     MOVE WS-BY TO WS-Y
     COMPUTE WS-Z = WS-BZ + 0.5
     COMPUTE WS-PX = WS-BX - 6
     MOVE 1 TO PL-MODE(WS-PLAYER)
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-PX WS-BY WS-BZ WS-INFESTED
     COMPUTE WS-X = WS-PX + 5.5
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     PERFORM COUNT-SILVERFISH
     MOVE WS-COUNT TO WS-BEFORE
     MOVE "mob_griefing" TO WS-RULE-NAME
     CALL "BR-RULE-FIND" USING WS-RULE-NAME WS-RULE-INDEX
     MOVE 0 TO WS-RULE-VALUE
     CALL "BR-RULE-SET" USING WS-RULE-INDEX WS-RULE-VALUE
     MOVE 1 TO EN-WAKE(WS-ROW)
     CALL "STDMOB-SILVERFISH-WAKE" USING WS-ROW
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-PX WS-BY WS-BZ WS-STATE
     MOVE "acceptance US15 20§9.1 wake-up friends without mob_griefing leaves the host block" TO TL-CASE
     MOVE WS-STONE TO TL-EXPECTED-N
     MOVE WS-STATE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM COUNT-SILVERFISH
     MOVE "acceptance US15 20§9.1 wake-up friends without mob_griefing lets no silverfish out" TO TL-CASE
     MOVE WS-BEFORE TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Merge with stone: without mob_griefing it never merges (300 ticks); with it, a stone block next to it becomes infested stone and the silverfish is gone.
     MOVE 0 TO WS-MADE
     MOVE EN-X(WS-ROW) TO WS-X
     MOVE EN-Y(WS-ROW) TO WS-Y
     MOVE EN-Z(WS-ROW) TO WS-Z
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 300
         MOVE 0 TO EN-WAKE(WS-ROW)
         MOVE WS-X TO EN-X(WS-ROW)
         MOVE WS-Y TO EN-Y(WS-ROW)
         MOVE WS-Z TO EN-Z(WS-ROW)
         CALL "MOB-STEP" USING WS-ROW
     END-PERFORM
     MOVE "acceptance US15 20§9.1 merge with stone needs mob_griefing" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-USED(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-RULE-VALUE
     CALL "BR-RULE-SET" USING WS-RULE-INDEX WS-RULE-VALUE
     COMPUTE WS-PX = FUNCTION INTEGER(WS-X)
     COMPUTE WS-PY = FUNCTION INTEGER(WS-Y)
     COMPUTE WS-PZ = FUNCTION INTEGER(WS-Z)
*>   A stone ring: the six neighbours of the silverfish's cell.
     COMPUTE WS-BX = WS-PX - 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-PY WS-PZ WS-STONE
     COMPUTE WS-BX = WS-PX + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-PY WS-PZ WS-STONE
     COMPUTE WS-BZ = WS-PZ - 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-PX WS-PY WS-BZ WS-STONE
     COMPUTE WS-BZ = WS-PZ + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-PX WS-PY WS-BZ WS-STONE
     COMPUTE WS-BY = WS-PY + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-PX WS-BY WS-PZ WS-STONE
     COMPUTE WS-BY = WS-PY - 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-PX WS-BY WS-PZ WS-STONE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 300 OR EN-USED(WS-ROW) = 0
         MOVE 0 TO EN-WAKE(WS-ROW)
         MOVE WS-X TO EN-X(WS-ROW)
         MOVE WS-Y TO EN-Y(WS-ROW)
         MOVE WS-Z TO EN-Z(WS-ROW)
         ADD 1 TO CW-TICKS
         CALL "MOB-STEP" USING WS-ROW
     END-PERFORM
     MOVE "acceptance US15 20§9.1 merge with stone discards the silverfish" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-USED(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-MADE
     COMPUTE WS-BX = WS-PX - 1
     PERFORM CHECK-INFESTED
     COMPUTE WS-BX = WS-PX + 1
     PERFORM CHECK-INFESTED
     COMPUTE WS-BZ = WS-PZ - 1
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-PX WS-PY WS-BZ WS-STATE
     IF WS-STATE = WS-INFESTED
         ADD 1 TO WS-MADE
     END-IF
     COMPUTE WS-BZ = WS-PZ + 1
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-PX WS-PY WS-BZ WS-STATE
     IF WS-STATE = WS-INFESTED
         ADD 1 TO WS-MADE
     END-IF
     COMPUTE WS-BY = WS-PY + 1
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-PX WS-BY WS-PZ WS-STATE
     IF WS-STATE = WS-INFESTED
         ADD 1 TO WS-MADE
     END-IF
     COMPUTE WS-BY = WS-PY - 1
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-PX WS-BY WS-PZ WS-STATE
     IF WS-STATE = WS-INFESTED
         ADD 1 TO WS-MADE
     END-IF
     MOVE "acceptance US15 20§9.1 merge with stone makes exactly one neighbour infested" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-MADE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A silverfish that has a target does not merge (the goal needs no target and no cooldown).
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE 1 TO EN-TARGET(WS-ROW)
     CALL "STDMOB-SILVERFISH-MERGE" USING WS-ROW
     MOVE "acceptance US15 20§9.1 a silverfish with a target does not merge" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-USED(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-ROW

*>   Every direction of the merge goal: 200 tries with the +x neighbour left as air (no host there), the other five stone.
     MOVE 0 TO WS-MERGES
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 200
         COMPUTE WS-BX = WS-PX - 1
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-PY WS-PZ WS-STONE
         COMPUTE WS-BX = WS-PX + 1
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-PY WS-PZ WS-AIR
         COMPUTE WS-BZ = WS-PZ - 1
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-PX WS-PY WS-BZ WS-STONE
         COMPUTE WS-BZ = WS-PZ + 1
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-PX WS-PY WS-BZ WS-STONE
         COMPUTE WS-BY = WS-PY + 1
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-PX WS-BY WS-PZ WS-STONE
         COMPUTE WS-BY = WS-PY - 1
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-PX WS-BY WS-PZ WS-STONE
         CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
         MOVE WS-J TO CW-TICKS
         CALL "STDMOB-SILVERFISH-MERGE" USING WS-ROW
         IF EN-USED(WS-ROW) = 0
             ADD 1 TO WS-MERGES
         ELSE
             CALL "ENTITY-REMOVE" USING WS-ROW
         END-IF
     END-PERFORM
     MOVE "acceptance US15 20§9.1 merge with stone happens about one try in ten in each of the other directions" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-MERGES >= 8 AND WS-MERGES <= 40
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 CHECK-INFESTED.
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-BX WS-PY WS-PZ WS-STATE
     IF WS-STATE = WS-INFESTED
         ADD 1 TO WS-MADE
     END-IF.
 COUNT-SILVERFISH.
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-TYPE
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM.
 END PROGRAM TEST-MOB-20-9-3.
 COPY CORETEST.
 COPY MOBSPTEST.
